FactoryGirl.define do
	factory :note_version do
    	title { Faker::Lorem.sentences(1) }
    	body { Faker::Lorem.paragraphs(5) }
    	external_note_id 'ABC123'
	end
end
