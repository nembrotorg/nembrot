class GoogleBooks
  include HTTParty

  base_uri Settings.books.google_books.domain

   attr_accessor :isbn, :title, :author, :lang, :published_date, :isbn_10, :isbn_13, :page_count, :google_books_id, :response

   def initialize(isbn)

    @isbn = isbn

    params = { 'country' => 'GB', 'q' => "ISBN:#{ isbn }" }
    response = self.class.get(Settings.books.google_books.path, :query => params)

    if response && response['items'].first
      response = response['items'].first
      volume_info = response['volumeInfo']

      @response = response
      @title = volume_info['title']
      @author = volume_info['authors'].join(', ')
      @lang = volume_info['language']
      @published_date = volume_info['publishedDate']
      @page_count = volume_info['pageCount']
      @google_books_id = response['id']
    end
    rescue => error
      puts "Error while fetching #{ isbn } from GoogleBooks."
      puts error
      puts error.backtrace
  end
end
