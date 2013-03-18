class EvernoteNote < CloudNote

  include EvernoteHelper

  def self.add_task(guid)
    evernote_note = self.where(:cloud_note_identifier => guid, :cloud_service_id => cloud_service.id).first_or_create
    evernote_note.dirtify
  end

  def self.sync_all
    need_syncdown.each { |cloud_note| cloud_note.syncdown_one }
  end

  def self.bulk_sync
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(
      notebookGuid: Settings.evernote.notebooks,
      words: Settings.evernote.instructions.required.join(' ').gsub(/^/, 'tag:').gsub(/ /, ' tag:'),
      order: 2,
      ascending: false
    )
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    cloud_notes = cloud_service.evernote_note_store.findNotesMetadata(cloud_service.evernote_oauth_token, filter, 0, 999, spec)
    cloud_notes.notes.each { |cloud_note| EvernoteNote.add_task(cloud_note.guid) }
  end

  def syncdown_one
    # TODO: If source_url is an image, download it (and keep as source...)

    increment_attempts

    cloud_note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)
    error_details = error_details(cloud_note_metadata)

    if cloud_notebook_not_required?(cloud_note_metadata.notebookGuid)
      destroy
      logger.info I18n.t('notes.sync.rejected.not_in_notebook', error_details)

    elsif !cloud_note_metadata.active
      update_attributes( :active => false )
      logger.info I18n.t('notes.sync.rejected.deleted_note', error_details)

    else
      cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid)

      if cloud_note_not_required?(cloud_note_tags)

        if note.nil?
          delete
        else
          note.update_attributes( :active => false )
          logger.info I18n.t('notes.sync.rejected.tag_missing', error_details)
          undirtify
        end
        
      elsif cloud_note_ignorable?(cloud_note_tags)
        logger.info I18n.t('notes.sync.rejected.ignore', error_details)
        max_out_attempts

      elsif cloud_note_updated?(cloud_note_metadata.updated)
        logger.info  I18n.t('notes.sync.rejected.not_latest', error_details)
        max_out_attempts

      else
        # If this is a new EvernoteNote, we only create a note here since many CloudNotes will be created
        #  and then destroyed if they're not required.
        build_note if note.nil?

        cloud_note_data = get_new_content_from_cloud(cloud_note_metadata)
        note.update_with_evernote_data(cloud_note_data, cloud_note_tags)
        update_with_data_from_cloud(cloud_note_data)
      end
    end

    rescue Evernote::EDAM::Error::EDAMUserException => error
      max_out_attempts
      sync_error('Evernote', guid, user_nickname, "User Exception: #{ Settings.evernote.errors[error.errorCode] } (#{ error.parameter }).")

    rescue Evernote::EDAM::Error::EDAMNotFoundException => error
      max_out_attempts
      sync_error('Evernote', guid, user_nickname, "Not Found Exception: #{ error.identifier }: #{ error.key }.")

    rescue Evernote::EDAM::Error::EDAMSystemException => error
      sync_error('Evernote', guid, user_nickname, "User Exception: error #{ error.errorCode }: #{ error.message }.")
  end

  private

  def self.cloud_service
    CloudService.where( :name => 'evernote' ).first_or_create
  end

  def guid
    cloud_note_identifier
  end

  def cloud_notebook_not_required?(cloud_notebook_identifier)
    !Settings.evernote.notebooks.include?(cloud_notebook_identifier)
  end

  def cloud_note_not_required?(cloud_note_tags)
    ((Settings.evernote.instructions.required & cloud_note_tags) != Settings.evernote.instructions.required)
  end

  def cloud_note_ignorable?(cloud_note_tags)
    (!(Settings.evernote.instructions.ignore & cloud_note_tags).empty?)
  end

  def cloud_note_updated?(note_metadata_updated)
    (note && note.external_updated_at >= Time.at(note_metadata_updated / 1000).to_datetime)
  end

  def update_with_data_from_cloud(note_data)
    update_attributes!(
      :note_id => note.id,
      :attempts => 0,
      :content_hash => note_data.contentHash,
      :update_sequence_number => note_data.updateSequenceNum,
      :dirty => false
    )
  end

  def get_new_content_from_cloud(note_data)
    note_data.content = note.body
    if note_data.contentHash != content_hash
      note_data = note_store.getNote(oauth_token, guid, true, false, false, false)
      note_data.content = ActionController::Base.helpers.sanitize(Nokogiri::XML(note_data.content).css("en-note").inner_html,
        :tags => Settings.notes.allowed_html_tags,
        :attributes => Settings.notes.allowed_html_attributes)
    end
    note_data
  end
end
