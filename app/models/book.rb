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
    self.author = response.author                      if self.author.blank? and response.respond_to? :author
    self.dewey_decimal = response.dewey_decimal        if self.dewey_decimal.blank? and response.respond_to? :dewey_decimal
    self.editor = response.editor                      if self.editor.blank? and response.respond_to? :editor
    self.format = response.format                      if self.format.blank? and response.respond_to? :format
    self.full_text = response.full_text                if self.full_text.blank? and response.respond_to? :full_text
    self.google_books_embeddable = response.google_books_embeddable if self.google_books_embeddable.blank? and response.respond_to? :google_books_embeddable
    self.google_books_id = response.google_books_id    if self.google_books_id.blank? and response.respond_to? :google_books_id
    self.introducer = response.introducer              if self.introducer.blank? and response.respond_to? :introducer
    self.isbn_10 = response.isbn_10                    if self.isbn_10.blank? and response.respond_to? :isbn_10
    self.isbn_13 = response.isbn_13                    if self.isbn_13.blank? and response.respond_to? :isbn_13
    self.lang = response.lang                          if self.lang.blank? and response.respond_to? :lang
    self.lcc_number = response.lcc_number              if self.lcc_number.blank? and response.respond_to? :lcc_number
    self.library_thing_id = response.library_thing_id  if self.library_thing_id.blank? and response.respond_to? :library_thing_id
    self.open_library_id = response.open_library_id    if self.open_library_id.blank? and response.respond_to? :open_library_id
    self.page_count = response.page_count              if self.page_count.blank? and response.respond_to? :page_count
    self.published_city = response.published_city      if self.published_city.blank? and response.respond_to? :published_city
    self.published_date = response.published_date      if self.published_date.blank? and response.respond_to? :published_date
    self.publisher = response.publisher                if self.publisher.blank? and response.respond_to? :publisher
    self.title = response.title                        if self.title.blank? and response.respond_to? :title
    self.translator = response.translator              if self.translator.blank? and response.respond_to? :translator
    self.weight = response.weight                      if self.weight.blank? and response.respond_to? :weight
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
