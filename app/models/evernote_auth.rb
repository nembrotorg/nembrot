# encoding: utf-8

class EvernoteAuth
  attr_accessor :auth

  def initialize
    self.auth = Authorization.where(provider: 'evernote', key: NB.evernote_key).first
    if auth.nil?
      CloudServiceMailer.auth_not_found('evernote').deliver
      SYNC_LOG.error I18n.t('notes.sync.rejected.not_authenticated', provider: 'Evernote', guid: '')
    end
  end

  def oauth_token
    auth.extra['access_token']['params']['oauth_token']
  end

  def note_store
    edam_note_store_url = auth.extra['access_token']['params']['edam_noteStoreUrl']
    note_store_transport = Thrift::HTTPClientTransport.new(edam_note_store_url)
    note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
    Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
  end

  def nickname
    auth.nickname
  end

  def url_prefix
    auth.extra['access_token']['params']['edam_webApiUrlPrefix']
  end
end
