class WorldCat
  include HTTParty

  base_uri Settings.books.world_cat.domain

  attr_accessor :isbn, :data, :title, :author, :author_statement, :publisher, :published_date, :translator, :introducer, :editor, :response

  def initialize(isbn)

    @isbn = isbn

    params = { 'recordSchema' => 'info:srw/schema/1/dc', 'servicelevel' => 'full', 'wskey' => Secret.auth.world_cat.api_key }
    response = self.class.get("#{ Settings.books.world_cat.path }#{ isbn }", :query => params)['oclcdcs']

    if response
      @response = response
      # @author = response['creator']
      # @title = response['title']
      # @author_statement = response['Title']
      @publisher = response['publisher']
      @published_date = "1-1-#{ response['date'] }"

      description = response['description'].join(' ')
      @translator = description.scan(/translated.*? by ([\w\. ]+\w)/i).join(', ')
      @introducer = description.scan(/introduc.*? by ([\w\. ]+\w)/i).join(', ')
      @editor = description.scan(/edited.*? by ([\w\. ]+\w)/i).join(', ')

    end
    rescue => error
      puts "Error while fetching #{ isbn } from WorldCat."
      puts error
      puts error.backtrace
  end
end
