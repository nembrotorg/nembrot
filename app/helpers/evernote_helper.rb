# encoding: utf-8

module EvernoteHelper
  # http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/

  include ApplicationHelper

  def oauth_token
    evernote_auth.oauth_token
  end

  def note_store
    evernote_auth.note_store
  end

  def user_nickname
    evernote_auth.nickname
  end

  def logger_details
    {
      provider: 'Evernote',
      guid: cloud_note_metadata.guid,
      title: cloud_note_metadata.title,
      username: user_nickname,
      id: evernote_note.id
    }
  end
end
