module EvernoteHelper
  #http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/
  require 'rubygems'
  require 'nokogiri'

  def add_evernote_task(guid)
    cloud_service = CloudService.where( :name => 'evernote' ).first_or_create
    cloud_note = CloudNote.where(:cloud_note_identifier => guid, :cloud_service_id => cloud_service.id).first_or_create
    cloud_note.update_attribute( :dirty, true )
    cloud_note.update_attribute( :sync_retries, 0 )
    # To do the actual updates asynchronously, commented out the following line.
    # Then add a cron job for EvernoteHelper.run_evernote_tasks.
    run_evernote_tasks
    "OK"
  end

  def run_evernote_tasks
    cloud_notes = CloudNote.needs_syncdown
    cloud_notes.each do |cloud_note|
      syncdown_note(cloud_note.cloud_note_identifier)
    end
  end

  def syncdown_note(guid)
    cloud_service = CloudService.where(:name => 'evernote').first_or_create
    auth = cloud_service.auth

    if !auth || auth.empty?
      CloudServiceMailer.auth_not_found('evernote').deliver
      logger.error t('notes.sync.rejected.not_authenticated', :provider => 'Evernote', :guid => guid)
    else
      edam_noteStoreUrl = auth.extra.access_token.params[:edam_noteStoreUrl]
      oauth_token = auth.extra.access_token.params[:oauth_token]
      note_store = get_note_store(edam_noteStoreUrl)

      note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)

      cloud_note = CloudNote.where(:cloud_note_identifier => note_metadata.guid, :cloud_service_id => cloud_service.id).first_or_create
      required_notebooks = Settings.evernote.notebooks.split(' ')
      required_tags = Settings.evernote.instructions.required.split(' ')
      ignore_instructions = Settings.evernote.instructions.ignore.split(' ')

      if !required_notebooks.include?(note_metadata.notebookGuid)
        cloud_note.destroy
        logger.info t('notes.sync.rejected.not_in_notebook', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
      elsif !note_metadata.active
        cloud_note.destroy
        logger.info t('notes.sync.rejected.deleted_note', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
      else
        note = Note.where(:id => cloud_note.note_id).first
        note_tags = note_store.getNoteTagNames(oauth_token, guid)
        if (required_tags & note_tags) != required_tags
          cloud_note.destroy
          logger.info t('notes.sync.rejected.tag_missing', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
        elsif !(ignore_instructions & note_tags).empty?
          logger.info t('notes.sync.rejected.ignore', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
        elsif note && note.external_updated_at >= Time.at(note_metadata.updated / 1000).to_datetime
          logger.info t('notes.sync.rejected.not_latest', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
        else
          if note_metadata.contentHash == cloud_note.content_hash
            # Content hasn't changed so no need to fetch.
            note_data = note_metadata
            note_content = note.body
          else
            note_data = note_store.getNote(oauth_token, guid, true, false, false, false)
            note_content = sanitize(Nokogiri::XML(note_data.content).css("en-note").inner_html,
              :tags => Settings.notes.allowed_html_tags.split(' '),
              :attributes => Settings.notes.allowed_html_attributes.split(' '))
          end
          create_or_update_note(cloud_note, note_data, note_content, note_tags, auth.info.nickname)
          logger.info t('notes.sync.updated', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
        end
      end
    end

  rescue => error
    CloudNoteMailer.syncdown_note_failed('evernote', guid, auth.info.nickname, error).deliver
    logger.info t('notes.sync.update_error', :provider => 'Evernote', :guid => guid)
    if cloud_note
      cloud_note.update_attribute(:sync_retries, cloud_note.sync_retries + 1)
    end
  end

  def get_note_store(edam_noteStoreUrl)
    noteStoreTransport = Thrift::HTTPClientTransport.new(edam_noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
  end

  def create_or_update_note(cloud_note, note_data, note_content, note_tags, username)
    note = Note.where(:id => cloud_note.note_id).first_or_create
    note.update_attributes(
      :title => note_data.title,
      :body => note_content,
      :external_updated_at => Time.at(note_data.updated / 1000).to_datetime,
      :tag_list => note_tags
    )
    cloud_note.update_attributes(
      :note_id => note.id,
      :sync_retries => 0,
      :content_hash => note_data.contentHash,
      :dirty => false
    )
    puts Nokogiri::XML(note_data.content).css("en-note").inner_html
  rescue => error
    CloudNoteMailer.syncdown_note_failed('evernote', note_data.guid, username, error).deliver
    logger.info t('notes.sync.update_error', :provider => 'Evernote', :guid => note_data.guid)
    cloud_note.update_attribute(:sync_retries, cloud_note.sync_retries + 1)
  end

  def check_version(user_store)
    version_ok = user_store.checkVersion("Evernote EDAMTest (Ruby)",
           Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
           Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
    unless version_ok
      logger.error t('notes.sync.version_not_ok', :provider => 'Evernote', :guid => guid)
      exit(1)
    end
  end
end
