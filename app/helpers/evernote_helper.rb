module EvernoteHelper
  # http://discussion.evernote.com/topic/15321-evernote-ruby-thrift-client-error/
  require 'rubygems'
  require 'nokogiri'
  require 'wtf_lang'

  include ApplicationHelper

  # If source_url is an image, download it (and keep as source...)

  private

    def sync_error(provider, guid, username, error)
      # CloudNoteMailer.syncdown_note_failed(provider, guid, username, error).deliver
      logger.info I18n.t('notes.sync.update_error', :provider => provider.titlecase, :guid => guid)
      logger.info error
    end

    def check_version(user_store)
      version_ok = user_store.checkVersion("Evernote EDAMTest (Ruby)",
        Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
        Evernote::EDAM::UserStore::EDAM_VERSION_MINOR
      )
      unless version_ok
        logger.error t('notes.sync.version_not_ok', :provider => 'Evernote', :guid => guid)
        exit(1)
      end
    end
end
