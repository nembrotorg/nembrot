FactoryGirl.define do
	factory :third_party do
		sequence( :name ) { "xABCDEF#{n}" }
	end
end
