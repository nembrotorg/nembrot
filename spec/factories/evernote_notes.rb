# encoding: utf-8

FactoryGirl.define do
  factory :evernote_note do
    evernote_auth
    note
    sequence(:cloud_note_identifier) { |n| "xABCDEF#{n}" }
    sequence(:id) { |n| "#{n}" }
  end
end
