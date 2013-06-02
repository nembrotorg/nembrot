class Source < ActiveRecord::Base

  include SyncHelper

  attr_accessible :title, :author, :editor, :introducer, :translator, :lang, :published_date, :pages, :isbn_10,
  :isbn_13, :page_count, :google_books_id, :publisher, :library_thing_id, :open_library_id,
  :tag, :dirty, :attempts, :notes

  has_and_belongs_to_many :notes

  default_scope :order => 'tag'

  # See http://stackoverflow.com/questions/3875564
  scope :citable, where("title IS NOT ? AND tag IS NOT ?", nil, nil)
  scope :publishable, where("title IS NOT ? AND tag IS NOT ?", nil, nil)
    .joins('left outer join notes_sources on sources.id = notes_sources.source_id')
    .where('notes_sources.source_id IS NOT ?', nil)
    .uniq
  scope :need_syncdown, where("dirty = ? AND attempts <= ?", true, Settings.notes.attempts)
  scope :maxed_out, where("attempts > ?", Settings.notes.attempts).order('updated_at')

  validates :isbn_13, :presence => true, :if => "isbn_10.blank?"
  validates :isbn_10, :isbn_13, :uniqueness => true, :allow_blank => true

  before_validation :make_tag, :if => (:author_changed? or :editor_changed? or :published_date_changed?) && "!published_date.blank?"
  before_validation :scan_notes_for_references, :if => :tag_changed?

  extend FriendlyId
  friendly_id :tag, use: :slugged

  def to_param
    slug
  end
end
