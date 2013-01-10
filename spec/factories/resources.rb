FactoryGirl.define do
  factory :resource do
    sequence( :cloud_resource_identifier ) { "xABCDEF#{n}" }
    note
  end
end
