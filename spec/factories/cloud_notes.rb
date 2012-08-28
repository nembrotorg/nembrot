FactoryGirl.define do
	factory :cloud_note do
		sequence( :cloud_note_identifier ) { "xABCDEF#{n}" }
		note
		cloud_service
	end
end
