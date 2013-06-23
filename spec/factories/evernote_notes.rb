FactoryGirl.define do
	factory :evernote_note do
		sequence( :cloud_note_identifier ) { |n| "xABCDEF#{n}" }
		note
		evernote_auth
	end
end
