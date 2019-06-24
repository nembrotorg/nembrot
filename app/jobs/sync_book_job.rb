class SyncBookJob < ActiveJob::Base
  queue_as :default

  def perform(book)
    book.populate!
  end
end
