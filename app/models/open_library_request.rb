# encoding: utf-8

class OpenLibraryRequest

  include HTTParty

  base_uri Settings.books.open_library.domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'format' => 'json', 'jscmd' => 'details', 'bibkeys' => "ISBN:#{ isbn }" }
    response = self.class.get(Settings.books.open_library.path, query: params)

    populate(response, isbn) if response && response["ISBN:#{ isbn }"]['details']

  rescue
    Rails.logger.error I18n.t('books.sync.failed.logger', provider: 'OpenLibrary', isbn: isbn)
  end

  def populate(response, isbn)
    response = response["ISBN:#{ isbn }"]['details']
    metadata = {}
    # TODO:
    # metadata['editor = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # metadata['introducer = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # metadata['translator = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    metadata['author']            = response.try { |r| Array(r['authors']).first['name'] }
    metadata['dewey_decimal']     = response.try { |r| Array(r['dewey_decimal_class']).first }
    metadata['lcc_number']        = response.try { |r| Array(r['lccn']).first }
    metadata['library_thing_id']  = response.try { |r| Array(r['identifiers']['librarything']).first }
    metadata['open_library_id']   = response.try { |r| Array(r['identifiers']['goodreads']).first }
    metadata['page_count']        = response.try { |r| r['number_of_pages'] }
    metadata['publisher']         = response.try { |r| Array(r['publishers']).first }
    metadata['title']             = response.try { |r| r['title'].titlecase }

    self.metadata = metadata unless metadata.empty?
  end
end
