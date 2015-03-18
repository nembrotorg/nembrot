# encoding: utf-8

FactoryGirl.define do
  factory :note do
    active true
    body { 'Fixed note content used to prevent multiple calls to VCR.' }
    hide false
    is_citation true
    lang 'en'
    listable true
    external_updated_at 1.day.ago
    external_created_at 2.days.ago # Not in schema but passed by EvernoteNoteRequest
    sequence(:id) { |n| "#{n}" }
    title { 'Fixed note title' }
    word_count nil
    instruction_list ['__LANG__EN']
  end
end
