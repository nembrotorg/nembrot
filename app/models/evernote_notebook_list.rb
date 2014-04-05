# encoding: utf-8

class EvernoteNotebookList

  attr_accessor :evernote_auth, :note_store, :list, :user

  include Evernotable

  def initialize(user)
    self.user = user
  end

  def array
    Rails.cache.exist?(cache_key) ? Rails.cache.fetch(cache_key) : fetch_notebooks_list
  end

  private

  def fetch_notebooks_list
    # REVIEW
    evernote_auth = EvernoteAuth.new(user)
    oauth_token = evernote_auth.oauth_token

    list = evernote_auth.note_store.listNotebooks(oauth_token)

    list_array = []
    list.each do |n|
      list_array.push({ name: n.name, guid: n.guid, default: n.defaultNotebook })
    end

    Rails.cache.write(cache_key, list_array, expires_in: Constant.cache_evernote_notebooks_for_minutes.minutes)

    return list_array
  end

  def cache_key
    cache_key = "evernote_notebooks_#{ user.id }"
  end
end
