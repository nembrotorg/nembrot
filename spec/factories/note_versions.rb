FactoryGirl.define do
	factory :note_version do
		title { Faker::Lorem.sentences(1) }
		body { Faker::Lorem.paragraphs(5) }
		sequence(:external_updated_at) { |n| (1000 - n).days.ago }
		note
	end
end
