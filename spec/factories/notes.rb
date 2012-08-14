FactoryGirl.define do
	factory :note do
		sequence(:external_identifier) { "ABCDEF#{n}" }
		factory :note_with_versions do
			ignore do
				versions_count 1
			end
			after(:create) do |note, evaluator|
				FactoryGirl.create_list(
					:note_version, 
					evaluator.versions_count,
					note: note)
			end
		end
	end
end
