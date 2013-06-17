# encoding: utf-8

class OpenLibrary
  include HTTParty

  base_uri Settings.books.open_library.domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'format' => 'json', 'jscmd' => 'details', 'bibkeys' => "ISBN:#{ isbn }" }
    response = self.class.get(Settings.books.open_library.path, query: params)

    populate(response, isbn) if response["ISBN:#{ isbn }"]
  end

  def populate(response, isbn)
    response = response["ISBN:#{ isbn }"]['details']
    metadata = {}
    # TODO:
    # metadata['editor = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # metadata['introducer = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # metadata['translator = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    metadata['author'] = response['authors'][0]['name']
    metadata['dewey_decimal'] = response['dewey_decimal_class'].try { first }
    metadata['lcc_number'] = response['lccn'].try { first }
    metadata['library_thing_id'] = response['identifiers'].try { response['identifiers']['librarything'].first }
    metadata['open_library_id'] = response['identifiers'].try { response['identifiers']['goodreads'].first }
    metadata['page_count'] = response['number_of_pages']
    metadata['publisher'] = response['publishers'].first
    metadata['title'] = response['title']

    self.metadata = metadata
  end
end
