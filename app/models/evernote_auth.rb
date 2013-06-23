# encoding: utf-8

class EvernoteAuth < ActiveRecord::Base

  has_many :evernote_notes, dependent: :destroy

  attr_encrypted :auth, key: Secret.database_encryption_key, marshal: true

  def oauth_token
    auth.extra.access_token.params[:oauth_token]
  end

  def note_store
    edam_note_store_url = auth.extra.access_token.params[:edam_noteStoreUrl]
    note_store_transport = Thrift::HTTPClientTransport.new(edam_note_store_url)
    note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
    Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
    rescue
      CloudServiceMailer.auth_not_found('evernote').deliver
      logger.error I18n.t('notes.sync.rejected.not_authenticated', provider: 'Evernote', guid: '')
  end

  def nickname
    auth.info.nickname
  end

  def url_prefix
    auth.extra.access_token.params[:edam_webApiUrlPrefix]
  end
end
