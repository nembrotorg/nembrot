# encoding: utf-8

module Pantographable
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticated_twitter_client
      Twitter::REST::Client.new do |config|
        config.consumer_key = Secret.auth.twitter.pantography.key
        config.consumer_secret = Secret.auth.twitter.pantography.secret
        config.access_token = Secret.auth.twitter.pantography.access_token
        config.access_token_secret = Secret.auth.twitter.pantography.access_secret
      end
    end
  end

  # REVIEW: Tweetstream would be more suitable for tracking our timeline
  #  but it is still incompatible with Ruby 2.0
  #  https://github.com/tweetstream/tweetstream/issues/117
  # def self.authenticated_tweetstream_client
  #   TweetStream.configure do |config|
  #     config.consumer_key       = Secret.auth.twitter.pantography.consumer_key
  #     config.consumer_secret    = Secret.auth.twitter.pantography.consumer_secret
  #     config.oauth_token        = Secret.auth.twitter.pantography.access_token
  #     config.oauth_token_secret = Secret.auth.twitter.pantography.access_secret
  #     config.auth_method        = :oauth
  #   end
  # end

  # def self.tweetstream_test
  #   TweetStream::Client.new.sample do |status|
  #     "#{status.text}"
  #   end
  # end
end
