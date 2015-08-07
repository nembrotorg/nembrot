class SyncNoteJob < ActiveJob::Base
  queue_as :high_priority

  def perform(evernote_note)
    EvernoteRequest.new.sync_down(evernote_note)
  end
end
