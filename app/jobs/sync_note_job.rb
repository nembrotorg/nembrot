evernote_note

class SyncNoteJob < ActiveJob::Base
  queue_as :default

  def perform(evernote_note)
    EvernoteRequest.new.sync_down(evernote_note)
  end
end
