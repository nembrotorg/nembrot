FactoryGirl.define do
  factory :resource do
    sequence( :cloud_resource_identifier ) { |n| "xABCDEF#{n}" }
    mime 'image/png'
    width 160
    height 90
    caption { Faker::Lorem.sentence(8) }
    description { Faker::Lorem.sentence(8) }
    source_url { Faker::Internet.domain_name }
    sequence( :external_updated_at ) { |n| ( 1000 - n ).days.ago }
    latitude Random.rand(50)
    longitude Random.rand(50)
    altitude Random.rand(1000)
    file_name { Faker::Lorem.word + '.png' }
    local_file_name { Faker::Lorem.word }
    sync_retries 0
    note
  end
end
