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

    list_hash = []
    list.each do |n|
      list_hash.push({
        name: n.name,
        guid: n.guid,
        default: n.defaultNotebook,
        shared: (!n.publishing.nil? || n.published? || !n.sharedNotebooks.nil? || !n.businessNotebook.nil?),
        business: !n.businessNotebook.nil?
      })
    end

    list_hash = list_hash.sort_by { |n| n.name }

    Rails.cache.write(cache_key, list_hash, expires_in: 0.minutes)

    return list_hash
  end

  def cache_key
    cache_key = "evernote_notebooks_#{ user.id }"
  end
end
