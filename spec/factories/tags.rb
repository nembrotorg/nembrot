FactoryGirl.define do
  factory :tag do
    name { Faker::Lorem.word }
    slug { name.parameterize }
    obsolete { false }
  end
end
