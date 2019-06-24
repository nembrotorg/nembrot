# encoding: utf-8

class Pantograph < ActiveRecord::Base

  include Pantographable

  belongs_to :pantographer

  validates_presence_of :text, :external_created_at, :tweet_id
  validates_uniqueness_of :text, :tweet_id

  default_scope { order('external_created_at DESC') }
  scope :by_self, -> { where(pantographer_id: pantography_twitter_user.id) }

  def self.alphabet
    NB.pantography_alphabet
  end

  def self.first_text
    alphabet.first
  end

  def self.last_text
    max_length.times.map { alphabet.last } .join
  end

  def self.max_length
    NB.pantography_max_length.to_i
  end

  def self.total_texts
    # Wrong! This does not take into consideration skipped texts
    # Total texts should be the sequence number of last text
    # ERROR: At the moment: Pantograph.|last_text|.sequence < Pantograph.total_texts => false
    (alphabet.length ** max_length) - 1 - skipped(last_text)
  end

  def self.skipped(text)
    # Calculate the number of pantographs that have been skipped due to repeated spaces.
    #  This is basically a triangular function on the length of the string - 1.
    #  So, for a string that is five letters long, we do 4 + 3 + 2 + 1.
    return 0 if text.length == 1 && alphabet.index(text.last) > alphabet.index(' ')
    return 1 unless text.length > 1
    use_length = text.length - 1
    use_length -= 1 unless alphabet.index(text.last) > alphabet.index(' ')
    # We add two for when the space appears in the beginning or the end
    #  This is the standard formula for calculating a triangular number
    #  Test with this more literal approach: (1..use_length).inject(:+) + 2
    use_length  * (use_length + 1) / 2 + 2
  end

  def self.total_duration
    (total_texts / (((60 * 60) / NB.pantography_frequency.to_i)  * 24 * NB.pantography_sidereal_year_in_days.to_i));
  end

  def self.sanitize(text, pantographer_id = nil)
    text = self.spamify(text) if pantographer_id == self.pantography_twitter_user.id
    text.truncate(NB.pantography_max_length.to_i, omission: '')
        .gsub(/"|“|”|\‘|\’/, "'")
        .gsub(/\&/, '+')
        .gsub(/\[\{/, '(')
        .gsub(/\]\}/, ')')
        .downcase
        .gsub(/[^#{ NB.pantography_alphabet_escaped }]/, '')
  end

  def self.publish_next
    next_pantograph = calculate_next
    while !tweet(next_pantograph) do
      # If the next pantograph fails, we log it and try the following one
      next_pantograph = calculate_after(next_pantograph)
    end
    next_pantograph
  end

  def self.tweet(text)
    # Replace @ and # characters before tweeting to avoid spamming other users
    #  These characters are unchanged as far as Pantography itself goes; they are stored intact.
    text = self.unspamify(text)
    tweet = authenticated_twitter_client.update(text)

    if tweet.text == text
      true # Tweet was successful
    else
      report_error("Twitter rejected message #{ text } with no error message.")
      false
    end

    rescue Twitter::Error => error
      if error == 'Over capacity'
        true # Although the tweet failed, we do not skip a pantograph
      else
        report_error("Twitter rejected message #{ text } with error, \"#{ error }\".")
        false
      end
  end

  def self.unspamify(text)
    text.gsub(/@/, 'A').gsub(/#/, 'H')
  end

  def self.spamify(text)
    text.gsub(/A/, '@').gsub(/H/, '#')
  end

  def self.report_error(error_message)
    PANTOGRAPHY_LOG.error error_message
    PantographMailer.tweet_failed(error_message).deliver
  end

  def self.calculate_next
    next_candidate = calculate_after(last_by_self_text)
    next_candidate = calculate_after(next_candidate) while Pantograph.where(text: next_candidate).exists?
    next_candidate = calculate_after(next_candidate) if looks_like_direct_message?(next_candidate)
    next_candidate
  end

  def self.last_by_self_text
    return '' if pantography_twitter_user.blank?
    last_pantographs = where(pantographer_id: pantography_twitter_user.id)
    last_pantographs.blank? ? '' : last_pantographs.first.text
  end

  def self.calculate_before(current)
    return first_text if current == first_text
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
    return last_text if current == last_text
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

  def self.looks_like_direct_message?(text)
    # Tweets that look like direct messages are refused silently by Twitter
    !text[/\b(d|m)$/i].nil?
  end

  def self.update_saved_timeline
    min_id = first.nil? ? 0 : first.tweet_id
    get_timeline(min_id)
  end

  def self.escape_text(text)
    URI.escape(text, /[\.,;:_@!?\/#()%'-+= ]/)
  end

  def to_param
    self.class.escape_text(text)
  end

  def previous_pantograph
    self.class.calculate_before(text)
  end

  def next_pantograph
    self.class.calculate_after(text)
  end

  def first_path
    Rails.application.routes.url_helpers.pantograph_path(self.class.first_text)
  end

  def last_path
    Rails.application.routes.url_helpers.pantograph_path(self.class.last_text)
  end

  def previous_path
    Rails.application.routes.url_helpers.pantograph_path(previous_pantograph)
  end

  def next_path
    Rails.application.routes.url_helpers.pantograph_path(next_pantograph)
  end

  def twitter_url
    pantographer.nil? ? '' : "http://twitter.com/#{ pantographer.twitter_screen_name }/status/#{ tweet_id }"
  end

  def scheduled_for
   (NB.pantography_start_date.to_datetime + (sequence * NB.pantography_frequency.to_i).seconds)
    .strftime('%A, %e %B %Y CE at %H:%M UTC')
    .gsub(/([\d]{9,})/) { |d| "<span title=\"#{ d }\">#{ d.to_f.to_s.gsub(/(\d)\.(\d+)+e\+(\d+)/, '\1.\2 x 10<sup>\3</sup>') }</span>" }
  end

  def sequence
    # Sequence number for this text (decimal)
    decimal = 0
    radix = self.class.alphabet.length
    text.split('').reverse.each_with_index do |letter, position|
      decimal += (self.class.alphabet.index(letter.to_s) + 1) * (radix ** position)
    end
    decimal -= self.class.skipped(text)
  end

  def percentage
    # Sequence as a percentage of total texts
    #{ }"<span title=\"#{ ((sequence * 100) / self.class.total_texts).to_f }%\">#{ (sequence * 100) / self.class.total_texts }</span>"
    (sequence * 100) / self.class.total_texts
  end

  private

  def self.get_timeline(min_id)
    tweets = authenticated_twitter_client.home_timeline(trim_user: true, min_id: min_id)

    # Notify if no Pantographs have been found
    # FIXME: This is only being trigerred when there are a lot of
    #  non-Pantography tweets to pad the list. Maybe something is wrong with
    #  min_id above.
    unless tweets.any? { |tweet| tweet.user.id == NB.pantography_twitter_user_id.to_i }
      Slack.ping("No new <a href=\"https://twitter.com/pantography\">pantographs</a> detected!", icon_url: NB.logo_url)
    end

    tweets.each do |tweet|
      user = Pantographer.where(twitter_user_id: tweet.user.id).first_or_create
      create(
            text: sanitize(tweet.text, user.id),
            external_created_at: tweet.created_at,
            tweet_id: tweet.id,
            pantographer_id: user.id
          )
      end
  end

  def self.pantography_twitter_user
    Pantographer.where(twitter_user_id: NB.pantography_twitter_user_id.to_i).first
  end
end
