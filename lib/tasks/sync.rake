namespace :sync do

  desc 'Asynchronous tasks'

  task all: :environment do |t, args|
    EvernoteNote.sync_all
    sync_associated
  end

  task bulk: :environment do |t, args|
    EvernoteNote.bulk_sync
    sync_associated
  end

  def sync_associated
    Resource.sync_all_binaries
    Book.sync_all
    Url.sync_all
  end
end
