FactoryGirl.define do
  factory :book do
    title { Faker::Lorem.sentence }
    author { Faker::Lorem.words(2).join(' ') }
    translator { Faker::Lorem.words(2) }
    introducer { Faker::Lorem.words(2) }
    editor { Faker::Lorem.words(2) }
    lang 'en'
    published_date 1.year.ago
    published_city { Faker::Lorem.word }
    publisher { Faker::Lorem.words(3) }
    isbn_10 "0123456789"
    isbn_13 "0123456789012"
    page_count Random.rand(500)
    google_books_id { Faker::Lorem.characters(10) }
    dirty false
    attempts 0
    library_thing_id { Faker::Lorem.characters(10) }
    open_library_id { Faker::Lorem.characters(10) }
  end
end
