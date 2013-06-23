# encoding: utf-8

module EvernoteHelper
  # http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/

  # DO WE STILL NEED THESE?
  require 'rubygems'
  require 'nokogiri'
  require 'wtf_lang'

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

  def error_details(cloud_note_metadata)
    { provider: 'Evernote', guid: cloud_note_metadata.guid, title: cloud_note_metadata.title, username: user_nickname }
  end
end
