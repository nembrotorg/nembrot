# encoding: utf-8

class Isbndb
  include HTTParty

  base_uri Settings.books.isbndb.domain

  attr_accessor :metadata

  def initialize(isbn)
    response = self.class.get("#{ Settings.books.isbndb.path }#{ Secret.auth.isbndb.api_key }/book/#{ isbn }")

    response = JSON.parse response

    populate(response) if response && response['data']
  end

  def populate(response)
    response = response['data'].first
    metadata = {}

    metadata['title'] = response['title']
    metadata['publisher'] = response['publisher_name']
    # metadata['title_long'] = response['Title'] if author_statement.nil?
    # metadata['author_statement'] = response[''] if title.nil?
    # Guess introducer and translator from authortext and description
    parsed_publisher_text = response['publisher_text'].scan(/(.*?) : (.*?)\, (c?\d\d\d\d)/)
    metadata['published_city'] = parsed_publisher_text[0][0] if parsed_publisher_text.size > 0
    metadata['published_date'] = parsed_publisher_text[0][2] if parsed_publisher_text.size > 0
    metadata['isbn_10'] = response['isbn10']
    metadata['isbn_13'] = response['isbn13']
    metadata['dewey_decimal'] = response['dewey_normal']
    metadata['lcc_number'] = response['lcc_number']

    self.metadata = metadata
  end
end
