namespace :joegattnet do

  desc 'Tasks grouped by interval to avoid reloading environment'

  task one_hour: :environment do |t, args|
    Pantograph.update_saved_timeline
    Pantograph.publish_next
    Pantographer.follow_followers
  end
end
