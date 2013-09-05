# encoding: utf-8

FactoryGirl.define do
  factory :link do
    attempts 0
    author { Faker::Lorem.words(2).join(' ') }
    canonical_url { "http://example3.com/#{ Faker::Lorem.words(2).join('/') }" }
    channel 'example3.com'
    dirty false
    error false
    lang 'en'
    modified '1-1-2001'
    paywall false
    publisher { Faker::Lorem.words(2).join(' ') }
    # slug 'example3.com'
    title { Faker::Lorem.words(2).join(' ') }
    url  { "http://example3.com/#{ Faker::Lorem.words(2).join('/') }" }
    website_name { Faker::Lorem.words(2).join(' ') }
  end
end
