# encoding: utf-8

class Link < ActiveRecord::Base

  include Syncable

  has_and_belongs_to_many :notes

  default_scope { order('channel') }

  # OPTIMIZE: Notes must be active and not hidden (publishable)
  scope :publishable, -> { where(dirty: false)
    .joins('left outer join links_notes on links.id = links_notes.link_id')
    .where('links_notes.link_id IS NOT ?', nil)
    .uniq }
  scope :need_syncdown, -> { where('dirty = ? AND attempts <= ?', true, Setting['channel.attempts'].to_i).order('updated_at') }
  scope :maxed_out, -> { where('attempts > ?', Setting['channel.attempts'].to_i).order('updated_at') }

  validates :url, presence: true, uniqueness: true
  validates :url, url: true
  validates :canonical_url, uniqueness: true, allow_blank: true
  validates :canonical_url, url: true, allow_blank: true

  before_validation :update_channel, if: :url_changed?
  before_validation :scan_notes_for_references, if: :url_changed?

  extend FriendlyId
  friendly_id :channel, use: :slugged

  def to_param
    channel
  end

  def self.grab_urls(text, source_url = nil)
    url_candidates = []
    url_candidates.push(source_url) unless source_url.blank?
    url_candidates_in_text = text.scan(%r((https?://[a-zA-Z0-9\./\-\?&%=_]+)[\,\.]?)).flatten
    url_candidates.push(url_candidates_in_text) unless url_candidates_in_text.empty?
    unless url_candidates.empty?
      url_candidates.flatten!
      url_candidates = url_candidates.reject { |url_candidate| url_candidate.match(%r(^http:\/\/[a-z0-9]*\.?#{ Constant.host })) } # Remove local
      url_candidates.each { |url_candidate| add_task(url_candidate) }
    end
  end

  def self.add_task(url_candidate)
    link = where(url: url_candidate).first_or_create
    link.dirty = true
    link.attempts = 0
    link.save!
    link
  end

  def self.sync_all
    need_syncdown.each { |link| link.populate! }
  end

  def populate!
    increment_attempts
    merge(LinkRequest.new(url).metadata)
    undirtify(true)
  end

  def name
    website_name.blank? ? domain : website_name
  end

  def headline
    title.blank? ? name : title
  end

  def domain
    url_or_canonical_url.scan(%r(https?://([a-z0-9\&\.\-]*))).flatten.first
  end

  def url_or_canonical_url
    canonical_url.blank? ? url : canonical_url
  end

  def protocol
    url_or_canonical_url.scan(/^(https?)/).flatten.first
  end

  def update_channel
    # REVIEW: For certain sites (e.g. blogs) we may want to add the 'channel': example.com/user
    self.channel = domain
  end

  def scan_notes_for_references
    self.notes = Note.where('body LIKE ?', "%#{ url }%")
  end
end
