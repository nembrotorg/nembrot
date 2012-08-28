FactoryGirl.define do
	factory :external do
		sequence( :external_identifier ) { "xABCDEF#{n}" }
		third_party
	end
end
