namespace :joegattnet do

  desc 'Tasks grouped by interval to avoid reloading environment'

  task one_minute: :environment do |t, args|
    EvernoteNote.sync_all
    sync_associated
  end

  task three_minutes: :environment do |t, args|
    EvernoteNote.sync_all
    sync_associated
  end

  task ten_minutes: :environment do |t, args|
    # Pantograph.update_saved_timeline
    # Pantograph.publish_next
  end

  task one_hour: :environment do |t, args|
    Pantograph.update_saved_timeline
    Pantograph.publish_next
    Pantographer.follow_followers
  end

  def sync_associated
    Resource.sync_all_binaries
    Book.sync_all
    Link.sync_all
  end
end
