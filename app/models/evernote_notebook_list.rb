# encoding: utf-8

class EvernoteNotebookList
  attr_accessor :evernote_auth, :note_store, :list, :user

  include Evernotable

  def initialize(user)
    self.user = user
  end

  def arry(cache = true)
    Rails.cache.exist?(cache_key) && cache ? Rails.cache.fetch(cache_key) : fetch_notebooks_list
  end

  private

  def fetch_notebooks_list
    # REVIEW
    evernote_auth = EvernoteAuth.new(user)
    oauth_token = evernote_auth.oauth_token

    list = evernote_auth.note_store.listNotebooks(oauth_token)

    list_array = []
    list.each do |n|
      list_array.push({
                        name: n.name,
        guid: n.guid,
        default: n.defaultNotebook,
        shared: (!n.publishing.nil? || n.published? || !n.sharedNotebooks.nil? || !n.businessNotebook.nil?),
        business: !n.businessNotebook.nil?
                      })
    end

    list_array = list_array.sort_by { |i| i[:name].downcase }

    Rails.cache.write(cache_key, list_array, expires_in: 3.hours)

    return list_array

    rescue Evernote::EDAM::Error::EDAMUserException => error
      return ['AUTH_EXPIRED'] if %w(NB.evernote_errors)[error.errorCode] == 'AUTH_EXPIRED'
  end

  def cache_key
    cache_key = "evernote_notebooks_#{ user.id }"
  end
end
