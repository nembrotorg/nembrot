# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme do
    premium false
    effects "MyString"
    map_style "MyString"
    name "MyString"
    slug "MyString"
    typekit_code "MyString"
    suitable_for_text false
    suitable_for_images false
    suitable_for_maps false
    suitable_for_video_and_sound false
  end
end
