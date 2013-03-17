class CloudService < ActiveRecord::Base
  attr_accessible :name

  has_many :cloud_notes, :dependent => :destroy

  attr_encrypted :auth, :key => Secret.database_encryption_key, :marshal => true

  validates :name, :presence => true, :uniqueness => true

  def evernote_oauth_token
    self.auth.extra.access_token.params[:oauth_token]
  end

  def evernote_note_store
    edam_note_store_url = self.auth.extra.access_token.params[:edam_noteStoreUrl]
    note_store_transport = Thrift::HTTPClientTransport.new(edam_note_store_url)
    note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
    Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
    rescue
      CloudServiceMailer.auth_not_found('evernote').deliver
      logger.error I18n.t('notes.sync.rejected.not_authenticated', :provider => 'Evernote', :guid => '')
  end

  def evernote_nickname
    self.auth.info.nickname
  end

  def evernote_url_prefix
    self.auth.extra.access_token.params[:edam_webApiUrlPrefix]
  end
end
