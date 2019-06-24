class UrlDecorateNoteJob < ActiveJob::Base
  queue_as :default

  def perform(note)
    Url.new(note)
  end
end
