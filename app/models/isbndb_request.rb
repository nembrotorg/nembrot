# encoding: utf-8

class IsbndbRequest
  include HTTParty

  base_uri NB.isbndb_domain

  attr_accessor :metadata

  def initialize(isbn)
    response = self.class.get("#{ NB.isbndb_path }#{ NB.isbndb_key }/book/#{ isbn }")

    response = JSON.parse response

    populate(response) if response && response['data']

  rescue
    SYNC_LOG.error I18n.t('books.sync.failed.logger', provider: 'Isbndb', isbn: isbn)
  end

  def populate(response)
    response = response['data'].first
    metadata = {}

    metadata['title']           = response.try { |r| r['title'].titlecase }
    metadata['publisher']       = response.try { |r| r['publisher_name'] }
    # metadata['title_long'] = response['Title'] if author_statement.nil?
    # metadata['author_statement'] = response[''] if title.nil?
    # Guess introducer and translator from authortext and description
    response.try do |r|
      parsed_publisher_text       = r['publisher_text'].scan(/(.*?) : (.*?)\, (c?\d\d\d\d)/)
      metadata['published_city']  = parsed_publisher_text[0][0] if parsed_publisher_text.size > 0
      metadata['published_date']  = parsed_publisher_text[0][2] if parsed_publisher_text.size > 0
    end
    metadata['isbn_10']         = response.try { |r| r['isbn10'] }
    metadata['isbn_13']         = response.try { |r| r['isbn13'] }
    metadata['dewey_decimal']   = response.try { |r| r['dewey_normal'] }
    metadata['lcc_number']      = response.try { |r| r['lcc_number'] }

    self.metadata = metadata unless metadata.empty?
  end
end
