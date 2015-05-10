# encoding: utf-8

FactoryGirl.define do
  factory :book do
    attempts 0
    author { 'Book Author' }
    dirty false
    editor { Faker::Lorem.words(2).join(' ') }
    google_books_id { Faker::Lorem.characters(10) }
    introducer { Faker::Lorem.words(2).join(' ') }
    isbn_10 '0140446044'
    isbn_13 '9780140446043'
    lang 'en'
    library_thing_id { Faker::Lorem.characters(10) }
    open_library_id { Faker::Lorem.characters(10) }
    page_count Random.rand(500)
    published_city { Faker::Lorem.word }
    published_date '2001-1-1'
    publisher { Faker::Lorem.words(3).join(' ') }
    sequence(:id) { |n| "#{n}" }
    title { 'Book title' }
    translator { Faker::Lorem.words(2).join(' ') }
  end
end
