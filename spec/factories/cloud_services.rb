FactoryGirl.define do
	factory :cloud_service do
		sequence( :name ) { "xABCDEF#{n}" }
    auth 'MOCK'
	end
end
