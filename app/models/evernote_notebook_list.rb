# encoding: utf-8

class EvernoteNotebookList

  attr_accessor :evernote_auth, :note_store, :list, :user

  include Evernotable

  def initialize(user)
    self.user = user
  end

  def array
    # REVIEW
    a = EvernoteAuth.new(user)
    oauth_token = a.oauth_token

    # REVIEW: This should be cached
    list = a.note_store.listNotebooks(oauth_token)

    list_array = []
    list.each do |n|
      list_array.push({ name: n.name, guid: n.guid, default: n.defaultNotebook })
    end

    list_array
  end
end
