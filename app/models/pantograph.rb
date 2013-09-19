# encoding: utf-8

class Pantograph < ActiveRecord::Base

  include Pantographable

  belongs_to :pantographer

  validates_presence_of :body, :external_created_at, :tweet_id
  validates_uniqueness_of :body, :tweet_id

  default_scope { order('external_created_at DESC') }

  def self.publish_next
    next_pantograph = calculate_next
    while !tweet(next_pantograph) do
      # If the next pantograph fails, we log it and try the following one
      next_pantograph = calculate_after(next_pantograph)
    end
  end

  def self.tweet(message)
    begin
      authenticated_twitter_client.update(message)
    rescue Twitter::Error => error
      unless error == 'Over capacity'
        error_message = "Twitter rejected message #{ message } with error, \"#{ error }\"."
        PANTOGRAPHY_LOG.error error_message
        PantographMailer.tweet_failed(error_message).deliver
        false
      else
        true
      end
    else
      true
    end
  end

  def self.calculate_next
    next_candidate = calculate_after(last_by_self_body)
    while Pantograph.where(body: next_candidate).exists? do
      next_candidate = calculate_after(next_candidate)
    end
    next_candidate
  end

  def self.last_by_self_body
    return '' if pantography_twitter_user.blank?
    last_pantographs = where(pantographer_id: pantography_twitter_user.id)
    last_pantographs.blank? ? '' : last_pantographs.first.body
  end

  def self.calculate_after(previous)
    alphabet = self.alphabet.split('')
    alphabet_without_space = alphabet - [' ']

    return alphabet.first if previous.blank?

    letters = previous.split('')
    cursor = letters.size - 1
    solved = false

    while !solved
      if letters[cursor] == alphabet.last
        letters[cursor] = alphabet.first
        if cursor > 0
          cursor -= 1
        else
          letters.unshift(alphabet.first)
          solved = true
        end
      else
        # Avoids leading, trailing and multiple spaces
        if cursor == 0 or cursor == letters.size - 1 or letters[cursor - 1] == ''
          letters[cursor] = alphabet_without_space[alphabet_without_space.index(letters[cursor]) + 1]
        else
          letters[cursor] = alphabet[alphabet.index(letters[cursor]) + 1]
        end
        solved = true
      end
    end
    letters.join
  end

  def self.update_saved_timeline
    min_id = first.nil? ? 0 : first.tweet_id
    get_timeline(min_id)
  end

  private

  def self.get_timeline(min_id)
    authenticated_twitter_client.home_timeline(trim_user: true, min_id: min_id).each do |tweet|
    user = Pantographer.where(twitter_user_id: tweet.user.id).first_or_create
    create(
          body: sanitize(tweet.text),
          external_created_at: tweet.created_at,
          tweet_id: tweet.id,
          pantographer_id: user.id
        )
    end
  end

  def self.pantography_twitter_user
    Pantographer.where(twitter_user_id: Settings.pantography.twitter_user_id).first
  end
end
