# encoding: utf-8

FactoryGirl.define do
  factory :note do
    active true
    body { 'Fixed note content used to prevent multiple calls to VCR.' }
    hide false
    is_citation true
    lang 'en'
    listable true
    sequence(:external_updated_at) { |n| (1000 - n).days.ago }
    sequence(:id) { |n| "#{n}" }
    title { 'Fixed note title' }
    word_count nil
  end
end
