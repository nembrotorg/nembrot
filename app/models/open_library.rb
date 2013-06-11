# encoding: utf-8

class OpenLibrary
  include HTTParty

  base_uri Settings.books.open_library.domain

  attr_accessor :isbn, :title, :author, :isbn_10, :isbn_13, :page_count, :publisher, :library_thing_id,
                :open_library_id, :response, :lcc_number, :dewey_decimal, :introducer, :editor, :translator

  def initialize(isbn)
    @isbn = isbn

    params = { 'format' => 'json', 'jscmd' => 'details', 'bibkeys' => "ISBN:#{ isbn }" }
    response = self.class.get(Settings.books.open_library.path, query: params)

    populate(response) if response["ISBN:#{ isbn }"]
  end

  def populate(response)
    response = response["ISBN:#{ isbn }"]['details']

    # TODO
    # @editor = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # @introducer = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    # @translator = response['by_statement'].try { scan(/translated by (.*?)[.]/) }
    @author = response['authors'][0]['name']
    @dewey_decimal = response['dewey_decimal_class'].try { first }
    @lcc_number = response['lccn'].try { first }
    @library_thing_id = response['identifiers'].try { response['identifiers']['librarything'].first }
    @open_library_id = response['identifiers'].try { response['identifiers']['goodreads'].first }
    @page_count = response['number_of_pages']
    @publisher = response['publishers'].first
    @response = response
    @title = response['title']

  end
end
