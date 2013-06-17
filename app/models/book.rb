# encoding: utf-8

class Book < Source

  def self.grab_isbns(text)
    text.scan(/([0-9\-]{9,17}X?)/).each { |isbn| add_task(isbn.first) }
  end

  def self.add_task(possible_isbn)
    possible_isbn.gsub!(/[^\dX]/, '')
    book = self.where(isbn_10: possible_isbn).first_or_create if possible_isbn.length == 10
    book = self.where(isbn_13: possible_isbn).first_or_create if possible_isbn.length == 13
    # We can't use dirtify here because this is a class method
    book.dirty = true
    book.attempts = 0
    book.save!
    book
  end

  def self.sync_all
    need_syncdown.each { |book| book.populate! }
  end

  def populate!
    increment_attempts
    merge(WorldCat.new(isbn))     if Settings.books.world_cat.active?
    merge(Isbndb.new(isbn))       if Settings.books.isbndb.active?
    merge(GoogleBooks.new(isbn))  if Settings.books.google_books.active?
    merge(OpenLibrary.new(isbn))  if Settings.books.open_library.active?
    undirtify(false) unless title.blank? || tag.blank?
    save!
  end

  def merge(response)
    response.metadata.each do |key, value|
      self.send("#{ key }=", value) if !value.blank? && self.send("#{ key }").blank?
    end
  end

  def scan_notes_for_references
    self.notes = Note.where('body LIKE ?', "%#{ tag }%")
  end

  def make_tag
    self.tag = "#{ author_surname } #{ published_date.year }"
  end

  def isbn
    (isbn_10.blank? ? isbn_13 : isbn_10)
  end

  def short_title
    title.gsub(/\:.*$/, '')
  end

  def author_or_editor
    author.blank? ? "#{ editor } #{ I18n.t('books.editor_short') }" : author
  end

  def author_sort
    (author.blank? ? editor : author).gsub(/([^ ]+?) ?([^ ]*)$/, '\\2, \\1')
  end

  def author_surname
    surname = (author.blank? ? editor : author).split(',')[0].scan(/([^ ]*)$/)[0][0]
    author.blank? ? "#{ surname } #{ I18n.t('books.editor_short') }" : surname
  end

  def headline
    "#{ author_surname }: #{ short_title }".html_safe
  end
end
