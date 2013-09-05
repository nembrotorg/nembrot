# encoding: utf-8

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'changeme'
    password_confirmation 'changeme'
    role 'admin'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end
