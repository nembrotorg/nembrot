# encoding: utf-8

FactoryGirl.define do
  factory :pantograph do
    text { Faker::Lorem.characters(140) }
    pantographer
    sequence(:external_created_at) { |n| (1000 - n).days.ago }
    sequence(:tweet_id) { |n| "#{n}" }
  end
end
