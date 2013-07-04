# encoding: utf-8

FactoryGirl.define do
  factory :note do
    active true
    body { Faker::Lorem.paragraph(5) }
    hide false
    is_citation false
    lang 'en'
    listable true
    sequence(:external_updated_at) { |n| (1000 - n).days.ago }
    sequence(:id) { |n| "#{n}" }
    title { Faker::Lorem.sentence(8) }
    word_count nil
  end
end
