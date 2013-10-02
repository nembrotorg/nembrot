# encoding: utf-8

class Pantograph < ActiveRecord::Base

  include Pantographable

  belongs_to :pantographer

  validates_presence_of :body, :external_created_at, :tweet_id
  validates_uniqueness_of :body, :tweet_id

  default_scope { order('external_created_at DESC') }
  scope :by_self, -> { where(pantographer_id: pantography_twitter_user.id) }

  def self.alphabet
    Settings.pantography.alphabet
  end

  def self.first_phrase
    alphabet.first
  end

  def self.last_phrase
    max_length.times.map { alphabet.last } .join
  end

  def self.max_length
    Settings.pantography.max_length
  end

  def self.total_phrases
    # Wrong! This does not take into consideration skipped phrases
    # Total phrases should be the sequence number of last phrase
    # ERROR: At the moment: Pantograph.|last_phrase|.sequence < Pantograph.total_phrases => false
    (alphabet.length ** max_length) - 1 - skipped(last_phrase)
  end

  def self.skipped(phrase)
    # Calculate the number of pantographs that have been skipped due to repeated spaces.
    #  This is basically a triangular function on the legth of the string - 1.
    #  So, for a string that is five letters long, we do 4 + 3 + 2 + 1.
    return 0 if phrase.length == 1 && alphabet.index(phrase.last) > alphabet.index(' ')
    return 1 unless phrase.length > 1
    use_length = phrase.length - 1
    use_length -= 1 unless alphabet.index(phrase.last) > alphabet.index(' ')
    (1..use_length).inject(:+) + 2 # We add two for when the space appears in the beginning or the end
  end

  def self.total_duration
    (total_phrases / (((60 * 60) / Settings.pantography.frequency)  * 24 * Settings.pantography.sidereal_year_in_days));
  end

  def self.sanitize(text)
    text.truncate(Settings.pantography.max_length, omission: '')
        .gsub(/"|“|”|\‘|\’/, "'")
        .gsub(/\&/, '+')
        .gsub(/\[\{/, '(')
        .gsub(/\]\}/, ')')
        .downcase
        .gsub(/[^#{ Settings.pantography.alphabet_escaped }]/, '')
  end

  def self.publish_next
    next_pantograph = calculate_next
    while !tweet(next_pantograph) do
      # If the next pantograph fails, we log it and try the following one
      next_pantograph = calculate_after(next_pantograph)
    end
    next_pantograph
  end

  def self.tweet(message)
    tweet = authenticated_twitter_client.update(message)

    if tweet.text == message
      true # Tweet was successful
    else
      report_error("Twitter rejected message #{ message } with no error message.")
      false
    end

    rescue Twitter::Error => error
      if error == 'Over capacity'
        true # Although the tweet failed, we do not skip a pantograph
      else
        report_error("Twitter rejected message #{ message } with error, \"#{ error }\".")
        false
      end
  end

  def self.report_error(error_message)
    PANTOGRAPHY_LOG.error error_message
    PantographMailer.tweet_failed(error_message).deliver
  end

  def self.calculate_next
    next_candidate = calculate_after(last_by_self_body)
    next_candidate = calculate_after(next_candidate) while Pantograph.where(body: next_candidate).exists?
    next_candidate
  end

  def self.last_by_self_body
    return '' if pantography_twitter_user.blank?
    last_pantographs = where(pantographer_id: pantography_twitter_user.id)
    last_pantographs.blank? ? '' : last_pantographs.first.body
  end

  def self.calculate_before(current)
    return first_phrase if current == first_phrase
    alphabet = self.alphabet.split('')
    return alphabet.first if current.blank?

    letters = current.split('')
    cursor = letters.size - 1
    solved = false

    until solved
      if letters[cursor] == alphabet.first
        letters[cursor] = alphabet.last
        if cursor > 0
          cursor -= 1
        else
          letters.shift
          solved = true
        end
      else
        letters[cursor] = alphabet[alphabet.index(letters[cursor]) - 1];
        solved = true
      end
    end
    letters.join         
  end

  def self.calculate_after(current)
    return last_phrase if current == last_phrase
    alphabet = self.alphabet.split('')
    alphabet_without_space = alphabet - [' ']

    return alphabet.first if current.blank?

    letters = current.split('')
    cursor = letters.size - 1
    solved = false

    until solved
      if letters[cursor] == alphabet.last
        letters[cursor] = alphabet.first
        if cursor > 0
          cursor -= 1
        else
          letters.unshift(alphabet.first)
          solved = true
        end
      else
        # Prevent leading, trailing and multiple spaces
        if cursor == 0 or cursor == letters.length - 1 or letters[cursor - 1] == ' '
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

  def self.escape_body(text)
    URI.escape(text, /[\.,;:_@!?\/#()%'-+= ]/)
  end

  def to_param
    self.class.escape_body(body)
  end

  def previous_escaped
    self.class.escape_body(previous_pantograph)
  end

  def previous_pantograph
    self.class.calculate_before(body)
  end

  def next_escaped
    self.class.escape_body(next_pantograph)
  end

  def next_pantograph
    self.class.calculate_after(body)
  end

  def first_path
    Rails.application.routes.url_helpers.pantograph_path(self.class.first_phrase)
  end

  def last_path
    Rails.application.routes.url_helpers.pantograph_path(self.class.last_phrase)
  end

  def previous_path
    Rails.application.routes.url_helpers.pantograph_path(previous_escaped)
  end

  def next_path
    Rails.application.routes.url_helpers.pantograph_path(next_escaped)
  end

  def twitter_url
    "http://twitter.com/#{ pantographer.twitter_screen_name }/status/#{ tweet_id }"
  end

  def scheduled_for
   (Settings.pantography.start_date.to_datetime + (sequence * 10).minutes).strftime('%A, %e %B %Y CE at %H:%M UTC')
    .gsub(/([\d]{9,})/) { |d| "<span title=\"#{ d }\">#{ d.to_f.to_s.gsub(/(\d)\.(\d+)+e\+(\d+)/, '\1.\2 x 10<sup>\3</sup>') }</span>" }
  end

  def sequence
    decimal = 0
    radix = self.class.alphabet.length
    body.split('').reverse.each_with_index do |letter, position|
      decimal += (self.class.alphabet.index(letter.to_s) + 1) * (radix ** position)
    end
    decimal -= self.class.skipped(body)
  end

  def percentage
    #{ }"<span title=\"#{ ((sequence * 100) / self.class.total_phrases).to_f }%\">#{ (sequence * 100) / self.class.total_phrases }</span>"
    (sequence * 100) / self.class.total_phrases
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
