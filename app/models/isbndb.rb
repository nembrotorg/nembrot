# encoding: utf-8

class Isbndb
  include HTTParty

  base_uri Settings.books.isbndb.domain

  attr_accessor :isbn, :data, :title, :publisher, :published_city, :published_date, :isbn_10, :isbn_13, :response,
                :dewey_decimal, :lcc_number

  def initialize(isbn)

    @isbn = isbn

    response = self.class.get("http://isbndb.com/api/v2/json/#{ Secret.auth.isbndb.api_key }/book/#{ isbn }")

    response = JSON.parse response

    populate(response) if response && response['data']
  end

  def populate(response)
    response = response['data'].first
    @response = response

    @title = response['title']
    @publisher = response['publisher_name']
    # @title_long = response['Title'] if author_statement.nil?
    # @author_statement = response[''] if title.nil?
    # Guess introducer and translator from authortext and description
    parsed_publisher_text = response['publisher_text'].scan(/(.*?) : (.*?)\, (c?\d\d\d\d)/)
    @published_city = parsed_publisher_text[0][0] if parsed_publisher_text.size > 0
    @published_date = parsed_publisher_text[0][2] if parsed_publisher_text.size > 0
    @isbn_10 = response['isbn10']
    @isbn_13 = response['isbn13']
    @dewey_decimal = response['dewey_normal']
    @lcc_number = response['lcc_number']
  end
end
