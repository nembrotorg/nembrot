# encoding: utf-8

class GoogleBooks
  include HTTParty

  base_uri Settings.books.google_books.domain

  attr_accessor :isbn, :title, :author, :lang, :published_date, :isbn_10, :isbn_13, :page_count, :google_books_id,
                :google_books_embeddable, :response

  def initialize(isbn)
    @isbn = isbn

    params = { 'country' => 'GB', 'q' => "ISBN:#{ isbn }", 'maxResults' => 1 }
    response = self.class.get(Settings.books.google_books.path, query: params)

    populate(response) if response && response['items'].first['volumeInfo']
  end

  def populate(response)
      response = response['items'].first
      volume_info = response['volumeInfo']

      # GoogleBooks does not return nil when a book is not found so we need to verify that the data returned is
      # relevant
      if volume_info['industryIdentifiers'].collect { |id| id['identifier'] }.include? isbn
        @response = response
        @google_books_embeddable = response['accessInfo']['embeddable']
        @title = volume_info['title']
        @author = volume_info['authors'].flatten.join(', ')
        @lang = volume_info['language']
        @published_date = volume_info['publishedDate']
        @page_count = volume_info['pageCount']
        @google_books_id = response['id']
      end
  end
end
