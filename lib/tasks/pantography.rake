namespace :pantography do

  desc 'Pantography tasks'

  task update_saved_timeline: :environment do |t, args|
    Pantograph.update_saved_timeline
  end

  task follow_followers: :environment do |t, args|
    Pantographer.follow_followers
  end

  task publish_next: :environment do |t, args|
    Pantograph.publish_next
  end
end
