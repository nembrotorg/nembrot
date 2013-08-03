# encoding: utf-8

class Book < ActiveRecord::Base

  include Syncable

  attr_accessible :title, :author, :editor, :introducer, :translator, :lang, :published_date, :published_city, :pages,
                  :isbn_10, :isbn_13, :page_count, :google_books_id, :publisher, :library_thing_id, :open_library_id,
                  :tag, :dirty, :attempts, :notes

  has_and_belongs_to_many :notes

  default_scope order: 'tag'

  # See http://stackoverflow.com/questions/3875564
  scope :citable, where('title IS NOT ? AND tag IS NOT ?', nil, nil)

  # OPTIMIZE: Notes must be active and not hidden (publishable)
  scope :publishable, where('title IS NOT ? AND tag IS NOT ?', nil, nil)
    .joins('left outer join books_notes on books.id = books_notes.book_id')
    .where('books_notes.book_id IS NOT ?', nil)
    .uniq
  scope :need_syncdown, where('dirty = ? AND attempts <= ?', true, Settings.notes.attempts).order('updated_at')
  scope :maxed_out, where('attempts > ?', Settings.notes.attempts).order('updated_at')

  validates :isbn_10, :isbn_13, uniqueness: true, allow_blank: true
  validates :isbn_13, presence: true, if: 'isbn_10.blank?'
  validates :isbn_10, isbn_format: { with: :isbn10 }, unless: 'isbn_10.blank?'
  validates :isbn_13, isbn_format: { with: :isbn13 }, unless: 'isbn_13.blank?'

  before_validation :update_tag, if: (:author_changed? || :editor_changed? || :published_date_changed?) && '!published_date.blank?'
  before_validation :scan_notes_for_references, if: :tag_changed?

  extend FriendlyId
  friendly_id :tag, use: :slugged

  def to_param
    slug
  end

  def self.grab_isbns(text)
    text.scan(/([0-9\-]{9,17}X?)/).each { |isbn_candidate| add_task(isbn_candidate.first) }
  end

  def self.add_task(isbn_candidate)
    isbn_candidate.gsub!(/[^\dX]/, '')
    book = where(isbn_10: isbn_candidate).first_or_create if isbn_candidate.length == 10
    book = where(isbn_13: isbn_candidate).first_or_create if isbn_candidate.length == 13
    # We can't use dirtify here because this is a class method
    if book
      book.dirty = true
      book.attempts = 0
      book.save
      book
    end
  end

  def self.sync_all
    need_syncdown.each { |book| book.populate! }
  end

  def isbn
    (isbn_10.blank? ? isbn_13 : isbn_10)
  end

  def short_title
    title.gsub(/\:.*$/, '')
  end

  def author_or_editor
    author.blank? ? "#{ editor } #{ I18n.t('books.show.editor_short') }" : author
  end

  def author_sort
    (author.blank? ? editor : author).gsub(/([^ ]+?) ?([^ ]*)$/, '\\2, \\1')
  end

  def author_surname
    return nil if author.blank? and editor.blank?
    surname = (author.blank? ? editor : author).split(',')[0].scan(/([^ ]*)$/)[0][0] 
    author.blank? ? "#{ surname } #{ I18n.t('books.show.editor_short') }" : surname
  end

  def headline
    "#{ author_surname }: <cite>#{ short_title }</cite>".html_safe
  end

  # REVIEW: this fails if protected and called through sync_all
  def populate!
    increment_attempts
    merge(WorldCatRequest.new(isbn).metadata)      if Settings.books.world_cat.active?
    merge(IsbndbRequest.new(isbn).metadata)        if Settings.books.isbndb.active?
    merge(GoogleBooksRequest.new(isbn).metadata)   if Settings.books.google_books.active?
    merge(OpenLibraryRequest.new(isbn).metadata)   if Settings.books.open_library.active?
    undirtify(false) unless metadata_missing?
    SYNC_LOG.info I18n.t('books.sync.updated', id: id, author: author, title: title, isbn: isbn)
    announce_metadata_missing if metadata_missing? && attempts == Settings.notes.attempts
    save!
  end

  private

  def scan_notes_for_references
    self.notes = Note.where('body LIKE ?', "%#{ tag }%")
  end

  def metadata_missing?
    title.blank? || author.blank? || published_date.blank?
  end

  def announce_metadata_missing
    BookMailer.metadata_missing(self).deliver
    SYNC_LOG.error I18n.t('books.sync.metadata_missing.logger', id: id, author: author, title: title, isbn: isbn)
  end

  def update_tag
    self.tag = "#{ author_surname } #{ published_date.year }"
  end
end
