namespace :nembrot do

  desc "Asynchronous tasks"

  task :sync_all_from_evernote => :environment do |t, args|
    EvernoteNote.sync_all
    Resource.sync_all_binaries
    puts "Done."
  end

  task :bulk_sync_from_evernote => :environment do |t, args|
    puts "Bulk syncing..."
    EvernoteNote.bulk_sync
    EvernoteNote.sync_all
    Resource.sync_all_binaries
    puts "Done."
  end
end
