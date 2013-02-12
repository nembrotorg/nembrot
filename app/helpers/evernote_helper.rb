module EvernoteHelper
  # http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/
  require 'rubygems'
  require 'nokogiri'
  require 'wtf_lang'

  include ApplicationHelper

  # If source_url is an image, download it (and keep as source...)

  def add_evernote_task(guid, run_tasks)
    cloud_service = CloudService.where( :name => 'evernote' ).first_or_create
    cloud_note = CloudNote.where(:cloud_note_identifier => guid, :cloud_service_id => cloud_service.id).first_or_create
    cloud_note.update_attribute( :dirty, true )
    cloud_note.update_attribute( :sync_retries, 0 )
    # To do the actual updates asynchronously, comment out the following line
    # and add a cron job for EvernoteHelper.run_evernote_tasks.
    if run_tasks
      run_evernote_tasks(cloud_service)
    end
    'OK'
  end

  def run_evernote_tasks(cloud_service)
    auth = cloud_service.auth

    if !auth || auth.empty?
      CloudServiceMailer.auth_not_found('evernote').deliver
      logger.error t('notes.sync.rejected.not_authenticated', :provider => 'Evernote', :guid => '')
    else
      edam_note_store_url = auth.extra.access_token.params[:edam_noteStoreUrl]
      oauth_token = auth.extra.access_token.params[:oauth_token]
      note_store = get_note_store(edam_note_store_url)

      dirty_cloud_notes = CloudNote.needs_syncdown
      dirty_cloud_notes.each do |cloud_note|
        syncdown_note(cloud_service, cloud_note.cloud_note_identifier, auth, oauth_token, note_store)
      end

      dirty_resources = Resource.needs_syncdown
      dirty_resources.each do |resource|
        syncdown_resource(resource, auth, oauth_token, note_store)
      end
    end
  end

  def syncdown_note(cloud_service, guid, auth, oauth_token, note_store)

    note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)

    cloud_note = CloudNote.where(:cloud_note_identifier => note_metadata.guid, :cloud_service_id => cloud_service.id).first_or_create
    required_notebooks = Settings.evernote.notebooks
    required_tags = Settings.evernote.instructions.required
    ignore_instructions = Settings.evernote.instructions.ignore

    if !required_notebooks.include?(note_metadata.notebookGuid)
      cloud_note.destroy
      logger.info t('notes.sync.rejected.not_in_notebook', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
    elsif !note_metadata.active
      # Don't destroy just set active to false so that versions are not lost immediately
      cloud_note.destroy
      logger.info t('notes.sync.rejected.deleted_note', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
    else
      note = Note.where(:id => cloud_note.note_id).first
      cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid)

      if (required_tags & cloud_note_tags) != required_tags
        # Don't destroy just set active to false so that versions are not lost immediately
        cloud_note.destroy
        logger.info t('notes.sync.rejected.tag_missing', :provider => 'Evernote', :guid => guid, :title => note_metadata.title, :username => auth.info.nickname)
      elsif !(ignore_instructions & cloud_note_tags).empty?
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
            :tags => Settings.notes.allowed_html_tags,
            :attributes => Settings.notes.allowed_html_attributes)
        end
        # cloud_note.update_attribute(:sync_retries, cloud_note.sync_retries + 1)
        create_or_update_note(cloud_note, note_data, note_content, cloud_note_tags, auth.info.nickname)
      end
    end

    rescue => error
      sync_error('evernote', guid, auth.info.nickname, error)
  end

  def syncdown_resource(resource, auth, oauth_token, note_store)
    file_location = resource.raw_location
    if !File.file?(file_location)
      increment_retries(resource)
      cloud_resource_data = note_store.getResourceData(oauth_token, resource.cloud_resource_identifier)

      File.open(file_location,"wb") do |file|
        file.write(cloud_resource_data)
      end

      # Also how do we delete images when a resource is deleted?
      # (A method in resource - checks file is not used by other resources first...?)

      # We check that the resource has been downloaded correctly, if so we unflag the resource.
      if Digest::MD5.file(file_location).digest == resource.data_hash
        reset_retries(resource)
      end
    end
  end

  def create_or_update_note(cloud_note, note_data, note_content, cloud_note_tags, username)
    note = Note.where(:id => cloud_note.note_id).first_or_create

    captions = note_content.scan(/^\s*cap:\s*(.*?)\s*$/i)
    descriptions = note_content.scan(/^\s*alt:\s*(.*?)\s*$/i)

    note_content.gsub!(/^.*cap:.*$/i, '')
    note_content.gsub!(/^.*alt:.*$/i, '')

    note.update_attributes!(
      :title => note_data.title,
      :body => note_content,
      # This should be done asynchronously
      :lang => (strip_tags("#{ note_data.title } #{ note_content }"[0..250])).lang,
      :latitude => note_data.attributes.latitude,
      :longitude => note_data.attributes.longitude,
      :external_updated_at => Time.at(note_data.updated / 1000).to_datetime,
      :author => note_data.attributes.author,
      :last_edited_by => note_data.attributes.lastEditedBy,
      :source => note_data.attributes.source,
      :source_application => note_data.attributes.sourceApplication,
      :source_url => note_data.attributes.sourceURL,
      :tag_list => cloud_note_tags.grep(/^[^_]/),
      :instruction_list => cloud_note_tags.grep(/^_/)
    )
    cloud_note.update_attributes!(
      :note_id => note.id,
      :sync_retries => 0,
      :content_hash => note_data.contentHash,
      :dirty => false
    )
    create_or_update_resources(note, note_data.resources, captions, descriptions)
    logger.info t('notes.sync.updated', :provider => 'Evernote', :guid => note_data.guid, :title => note.title, :username => username)
    rescue => error
      sync_error('evernote', note_data.guid, username, error)
      increment_retries(cloud_note)
  end

  def create_or_update_resources(note, cloud_resources, captions, descriptions)
    # When a note contains both images and downloads, the alt/cap is disrupted
    if cloud_resources
      cloud_resources.each_with_index do |cloud_resource, index|
        resource = Resource.where(:cloud_resource_identifier => cloud_resource.guid).first_or_create
        resource.update_attributes!(
          :note_id => note.id,
          :mime => cloud_resource.mime,
          :width => cloud_resource.width,
          :height => cloud_resource.height,
          :caption => captions[index] ? captions[index][0] : '',
          :description => descriptions[index] ? descriptions[index][0] : '',

          #Add captions to videos?
          #Add fx (similarly)
          #Remove credit - should just go with caption?
          #:credit => '',
          :source_url => cloud_resource.attributes.sourceURL,
          :external_updated_at => cloud_resource.attributes.timestamp ? Time.at(cloud_resource.attributes.timestamp / 1000).to_datetime : nil,
          :latitude => cloud_resource.attributes.latitude,
          :longitude => cloud_resource.attributes.longitude,
          :altitude => cloud_resource.attributes.altitude,
          :camera_make => cloud_resource.attributes.cameraMake,
          :camera_model => cloud_resource.attributes.cameraModel,
          :file_name => cloud_resource.attributes.fileName,
          :attachment => cloud_resource.attributes.attachment,
          :data_hash => cloud_resource.data.bodyHash,
          :dirty => (cloud_resource.data.bodyHash != resource.data_hash),
          :sync_retries => 0
        )
      end
    end
  end

  private
    def get_note_store(edam_note_store_url)
      note_store_transport = Thrift::HTTPClientTransport.new(edam_note_store_url)
      note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
      Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
    end

    def sync_error(provider, guid, username, error)
      CloudNoteMailer.syncdown_note_failed(provider, guid, username, error).deliver
      logger.info t('notes.sync.update_error', :provider => provider, :guid => guid)
      logger.info error.backtrace.join("\n")
    end

    def increment_retries(record)
      record.update_attributes(:sync_retries => record.sync_retries + 1)
    end

    def reset_retries(record)
      record.update_attributes(:sync_retries => 0, :dirty => 0)
    end

    def check_version(user_store)
      version_ok = user_store.checkVersion("Evernote EDAMTest (Ruby)",
        Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
        Evernote::EDAM::UserStore::EDAM_VERSION_MINOR
      )
      unless version_ok
        logger.error t('notes.sync.version_not_ok', :provider => 'Evernote', :guid => guid)
        exit(1)
      end
    end
end
