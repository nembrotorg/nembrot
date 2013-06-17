# encoding: utf-8

class GoogleBooks
  include HTTParty

  base_uri Settings.books.google_books.domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'country' => 'GB', 'q' => "ISBN:#{ isbn }", 'maxResults' => 1 }
    response = self.class.get(Settings.books.google_books.path, query: params)

    populate(response, isbn) if response && response['items'].first['volumeInfo']
  end

  def populate(response, isbn)
      response = response['items'].first
      volume_info = response['volumeInfo']
      metadata = {}

      # GoogleBooks does not return nil when a book is not found so we need to verify that the data returned is
      # relevant
      if volume_info['industryIdentifiers'].collect { |id| id['identifier'] }.include? isbn
        metadata['google_books_embeddable'] = response['accessInfo']['embeddable']
        metadata['title'] = volume_info['title']
        metadata['author'] = volume_info['authors'].flatten.join(', ')
        metadata['lang'] = volume_info['language']
        metadata['published_date'] = volume_info['publishedDate']
        metadata['page_count'] = volume_info['pageCount']
        metadata['google_books_id'] = response['id']
      end

    self.metadata = metadata
  end
end
