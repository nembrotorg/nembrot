# encoding: utf-8

FactoryGirl.define do
  factory :pantographer do
    twitter_screen_name { Faker::Lorem.words(1).first }
    twitter_real_name { Faker::Lorem.words(2).join(' ') }
    twitter_user_id { ENV['pantography_twitter_user_id'].to_i }
  end
end
