FactoryGirl.define do
	factory :note_version do
    	title { Faker::Lorem.sentences(1) }
    	body { Faker::Lorem.paragraphs(5) }
    	version 1
    	note_id 1
	end
end
