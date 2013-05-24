FactoryGirl.define do
	factory :note do
		title { Faker::Lorem.sentence(8) }
		body { Faker::Lorem.paragraph(5) }
		sequence( :external_updated_at ) { |n| ( 1000 - n ).days.ago }
    active true
    hide false
    lang 'en'
	end
end
