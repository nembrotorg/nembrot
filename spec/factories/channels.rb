FactoryGirl.define do
  factory :channel do
    name 'The Discovery Channel'
    theme 'inverse'
    notebooks 'NOTEBOOK_1'
    slug 'the-discovery-channel'
    user
  end
end
