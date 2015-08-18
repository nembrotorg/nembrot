# encoding: utf-8

class WorldCatRequest
  include HTTParty

  base_uri NB.world_cat_domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'recordSchema' => 'info:srw/schema/1/dc', 'servicelevel' => 'full',
               'wskey' => NB.world_cat_key }
    response = self.class.get("#{ NB.world_cat_path }#{ isbn }", query: params)

    populate(response, isbn) if response && response['oclcdcs']

  rescue
    SYNC_LOG.error I18n.t('books.sync.failed.logger', provider: 'WorldCat', isbn: isbn)
  end

  def populate(response, _isbn)
    response = response['oclcdcs']
    metadata = {}
    # OPTIONAL:
    #  @author = response['creator']
    #  @title = response['title']
    #  @author_statement = response['Title']
    metadata['publisher']       = response.try { |r| Array(r['publisher']).first }
    metadata['published_date']  = response.try { |r| "1-1-#{ r['date'].scan(/\d\d\d\d/).first }" }

    if response['description']
      response.try do |r|
        description = Array(r['description']).join(' ')
        # OPTIMIZE: These regular expressions can be refined (by [A-Z]{1}\w)
        metadata['editor'] = description.scan(/edited.*? by ([\w ]+\w)/i).join(', ')
        metadata['introducer'] = description.scan(/introduc.*? by ([\w ]+\w)/i).join(', ')
        metadata['translator'] = description.scan(/translated.*? by ([\w ]+\w)/i).join(', ')
      end
    end

    self.metadata = metadata unless metadata.empty?
  end
end
