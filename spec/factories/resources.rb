# encoding: utf-8

FactoryGirl.define do
  factory :resource do
    altitude Random.rand(1000)
    caption { Faker::Lorem.sentence(8) }
    description { Faker::Lorem.sentence(8) }
    dirty false
    file_name { Faker::Lorem.word + '.png' }
    height 900
    mime 'image/png'
    note
    sequence(:cloud_resource_identifier) { |n| "xABCDEF#{n}" }
    sequence(:external_updated_at) { |n| (1000 - n).days.ago }
    sequence(:id) { |n| "#{n}" }
    source_url { Faker::Internet.domain_name }
    width 1600
  end
end
