# encoding: utf-8

FactoryGirl.define do
  factory :pantographer do
    twitter_screen_name { Faker::Lorem.words(1).first }
    twitter_real_name { Faker::Lorem.words(2).join(' ') }
    twitter_user_id Constant.pantography.twitter_user_id
  end
end
