class Isbndb
  include HTTParty

  base_uri Settings.books.isbndb.domain

   attr_accessor :isbn, :data, :title, :publisher, :published_city, :published_date, :isbn_10, :isbn_13, :response

   def initialize(isbn)

    @isbn = isbn

    params = { 'value1' => isbn, 'results' => 'texts', 'index1' => 'isbn', 'access_key' => Secret.auth.isbndb.api_key }
    response = self.class.get(Settings.books.isbndb.path, :query => params)['ISBNdb']['BookList']['BookData']

    if response
      @response = response
      @title = response['Title']
      # @title_long = response['Title'] if author_statement.nil?
      # @author_statement = response[''] if title.nil?
      # Guess introducer and translator from authortext and description
      parsed_publisher_text = response['PublisherText']['__content__'].scan(/(.*?) : ?(.*?), c?(\d\d\d\d)/)
      @publisher = parsed_publisher_text[0][1] if parsed_publisher_text.size > 0
      @published_city = parsed_publisher_text[0][0] if parsed_publisher_text.size > 0
      @published_date = parsed_publisher_text[0][2] if parsed_publisher_text.size > 0
      @isbn_10 = response['isbn']
      @isbn_13 = response['isbn13']
    end
    rescue => error
      puts "Error while fetching #{ isbn } from IsbnDB."
      puts error
      puts error.backtrace
  end
end
