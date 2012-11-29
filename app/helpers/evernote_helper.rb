module EvernoteHelper
  #http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/
  require 'rubygems'
  require 'evernote'
  require 'nokogiri'

  def evernote_add_task(guid)
    # Add guid to Tasks :type => 0, :metadata => guid, :status => false
    evernote_syncdown_note(guid)
  end

  # def evernote_next_task
    # Runs next task with :type => 0, :metadata => guid, :status => false
  # end

  # def evernote_all_tasks
    # As above but recursive until all are true
  # end

  def evernote_syncdown_note(guid)
    user_store = get_user_store
    check_evernote_version(user_store)
    auth_token = Secret.evernote.developer_token
    note_store = get_note_store(auth_token, user_store)

    note_data = note_store.getNote(auth_token, guid, true, true, false, false)
    create_or_update_note(auth_token, note_store, note_data)
  end

  def get_user_store
    config = {
      :username => Secret.evernote.username,
      :password => Secret.evernote.password,
      :consumer_key => Secret.evernote.consumer_key,
      :consumer_secret => Secret.evernote.consumer_secret
    }
    Evernote::UserStore.new(Settings.evernote.user_store_url, config)
  end

  def get_note_store(auth_token, user_store)
    note_store_url = user_store.getNoteStoreUrl(auth_token)
    note_store_transport = Thrift::HTTPClientTransport.new(note_store_url)
    note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
    Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
  end

  def create_or_update_note(auth_token, note_store, note_data)
    cloud_service = CloudService.where( :name => 'Evernote' ).first_or_create
    cloud_note = CloudNote.where(:cloud_note_identifier => note_data.guid, :cloud_service_id => cloud_service.id).first_or_initialize

    note = Note.where(:id => cloud_note.note_id).first_or_initialize

    note.assign_attributes(
      :title => note_data.title,
      :body =>
        sanitize(Nokogiri::XML(note_data.content).css("en-note").inner_html,
          :tags => Settings.notes.allowed_html_tags.split(' '),
          :attributes => Settings.notes.allowed_html_attributes.split(' ')),
      :external_updated_at => Time.at(note_data.updated / 1000).to_datetime
    )
    if !note_data.tagGuids.nil?
      note.tag_list = create_or_update_tags(auth_token, note_store, note_data)
    end
    note.save

    cloud_note.note_id = note.id
    cloud_note.save
  end

  def create_or_update_tags(auth_token, note_store, note_data)
    new_note_tags = Array.new
    note_data.tagGuids.each do |tag|
      tag_data = note_store.getTag(auth_token, tag)
      new_note_tags.push(tag_data.name)
    end
    new_note_tags
  end

  def check_evernote_version(user_store)
    version_ok = user_store.checkVersion("Evernote EDAMTest (Ruby)",
           Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
           Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
    # Needs better error
    puts "Is my Evernote API version up to date?  #{version_ok}"
    puts
    exit(1) unless version_ok
  end
end
