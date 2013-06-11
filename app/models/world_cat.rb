# encoding: utf-8

class WorldCat

  include HTTParty

  base_uri Settings.books.world_cat.domain

  attr_accessor :isbn, :data, :title, :author, :author_statement, :publisher, :published_date, :translator,
                :introducer, :editor, :response

  def initialize(isbn)
    @isbn = isbn

    params = { 'recordSchema' => 'info:srw/schema/1/dc', 'servicelevel' => 'full',
               'wskey' => Secret.auth.world_cat.api_key }
    response = self.class.get("#{ Settings.books.world_cat.path }#{ isbn }", query: params)

    populate(response) if response && response['oclcdcs']
  end

  def populate(response)
    response = response['oclcdcs']
    @response = response
    # OPTIONAL
    # @author = response['creator']
    # @title = response['title']
    # @author_statement = response['Title']
    @publisher = response['publisher'].is_a?(Array) ? response['publisher'].first : response['publisher']
    @published_date = "1-1-#{ response['date'].scan(/\d\d\d\d/).first }"
    if response['description']
      description = response['description'].is_a?(Array) ? response['description'].join(' ') : response['description']
      # REVIEW: These regular expressions can be refined (by [A-Z]{1}\w)
      @editor = description.scan(/edited.*? by ([\w ]+\w)/i).join(', ')
      @introducer = description.scan(/introduc.*? by ([\w ]+\w)/i).join(', ')
      @translator = description.scan(/translated.*? by ([\w ]+\w)/i).join(', ')
    end
  end
end
