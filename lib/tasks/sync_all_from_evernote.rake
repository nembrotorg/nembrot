namespace :nembrot do

  desc "Asynchronous tasks"

  task :sync_all_from_evernote => :environment do |t, args|

    CloudNote.sync_all_from_evernote
    Resource.sync_all_binaries
    puts "Done."
  end
end
