# encoding: utf-8

class WorldCat

  include HTTParty

  base_uri Settings.books.world_cat.domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'recordSchema' => 'info:srw/schema/1/dc', 'servicelevel' => 'full',
               'wskey' => Secret.auth.world_cat.api_key }
    response = self.class.get("#{ Settings.books.world_cat.path }#{ isbn }", query: params)

    populate(response) if response && response['oclcdcs']
  end

  def populate(response)
    response = response['oclcdcs']
    metadata = {}
    # OPTIONAL:
    #  @author = response['creator']
    #  @title = response['title']
    #  @author_statement = response['Title']
    metadata['publisher'] = Array(response['publisher']).first
    metadata['published_date'] = "1-1-#{ response['date'].scan(/\d\d\d\d/).first }"
    if response['description']
      description = Array(response['description']).join(' ')
      # OPTIMIZE: These regular expressions can be refined (by [A-Z]{1}\w)
      metadata['editor'] = description.scan(/edited.*? by ([\w ]+\w)/i).join(', ')
      metadata['introducer'] = description.scan(/introduc.*? by ([\w ]+\w)/i).join(', ')
      metadata['translator'] = description.scan(/translated.*? by ([\w ]+\w)/i).join(', ')
    end

    self.metadata = metadata
  end
end
