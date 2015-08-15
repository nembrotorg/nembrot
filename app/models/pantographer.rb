# encoding: utf-8

class Pantographer < ActiveRecord::Base
  include Pantographable

  has_many :pantographs, dependent: :destroy

  validates_presence_of :twitter_screen_name, :twitter_real_name, :twitter_user_id
  validates_uniqueness_of :twitter_screen_name, :twitter_user_id

  before_validation :get_user_details, on: :create
  after_save :follow_user, on: :create

  def self.follow_followers
    client = Pantographer.authenticated_twitter_client
    # REVIEW: Can we just get id using friends_ids?
    #  Can we send the array straight to follow/unfollow
    followers = client.followers(skip_status: true, include_user_entities: false).to_a
    friends = client.friends(skip_status: true, include_user_entities: false).to_a
    # REVIEW: Sometimes Twitter returns empty lists for followers, causing us to re-follow everyone)
    #  So here we make sure that neither of the lists is empty, unless we're starting from scratch.
    #  This is not fool-proof, of course. There should be a better way of detecting this.
    unless (followers.empty? || friends.empty?) && !Pantographer.all.empty?
      (friends - followers).each { |user| client.unfollow(user.id) }
      (followers - friends).each { |user| client.follow(user.id) }
    end
  end

  def twitter_url
    "http://twitter.com/#{ twitter_screen_name }"
  end

  protected

  def get_user_details
    twitter_user = Pantographer.authenticated_twitter_client.user(twitter_user_id)
    self.twitter_screen_name = twitter_user.screen_name
    self.twitter_real_name = twitter_user.name
  end

  def follow_user
    Pantographer.authenticated_twitter_client.follow(twitter_user_id) unless twitter_user_id.to_s == NB.pantography_twitter_user_id
  end
end
