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

    if auth.empty?
      CloudServiceMailer.auth_not_found('evernote').deliver
      logger.error t('notes.sync.rejected.not_authenticated', :provider => 'Evernote', :guid => guid)
    else
      edam_noteStoreUrl = auth.extra.access_token.params[:edam_noteStoreUrl]
      oauth_token = auth.extra.access_token.params[:oauth_token]
      note_store = get_note_store(edam_noteStoreUrl)

      note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)
      cloud_note = CloudNote.where(:cloud_note_identifier => note_metadata.guid, :cloud_service_id => cloud_service.id).first_or_create

      required_notebooks = Settings.evernote.notebooks.split(' ')
      required_tags = Settings.evernote.tags.split(' ')

      if !required_notebooks.include?(note_metadata.notebookGuid)
        cloud_note.destroy
        logger.info t('notes.sync.rejected.not_in_notebook', :provider => 'Evernote', :guid => guid, :title => note_metadata.title)
      else
        note = Note.where(:id => cloud_note.note_id).first
        note_tags = note_store.getNoteTagNames(oauth_token, guid)
        if (required_tags & note_tags) != required_tags 
          cloud_note.destroy
          logger.info t('notes.sync.rejected.tag_missing', :provider => 'Evernote', :guid => guid, :title => note_metadata.title)
        elsif note && note.external_updated_at >= Time.at(note_metadata.updated / 1000).to_datetime
          logger.info t('notes.sync.rejected.not_latest', :provider => 'Evernote', :guid => guid, :title => note_metadata.title)
        else
          note_data = note_store.getNote(oauth_token, guid, true, true, false, false)
          create_or_update_note(cloud_note, oauth_token, note_store, note_data, note_tags, auth.info.nickname)
          logger.info t('notes.sync.updated', :provider => 'Evernote', :guid => guid, :title => note_metadata.title)
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

  def create_or_update_note(cloud_note, oauth_token, note_store, note_data, note_tags, username)
    note = Note.where(:id => cloud_note.note_id).first_or_create
    note.update_attributes(
      :title => note_data.title,
      :body => 
        sanitize(Nokogiri::XML(note_data.content).css("en-note").inner_html,
          :tags => Settings.notes.allowed_html_tags.split(' '),
          :attributes => Settings.notes.allowed_html_attributes.split(' ')),
      :external_updated_at => Time.at(note_data.updated / 1000).to_datetime,
      :tag_list => note_tags
    )
    cloud_note.update_attributes(
      :note_id => note.id,
      :sync_retries => 0,
      :dirty => false
    )
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
