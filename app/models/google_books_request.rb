# encoding: utf-8

class GoogleBooksRequest
  include HTTParty

  base_uri NB.google_books_domain

  attr_accessor :metadata

  def initialize(isbn)
    params = { 'country' => 'GB', 'q' => "ISBN:#{ isbn }", 'maxResults' => 1 }
    response = self.class.get(NB.google_books_path, query: params)

    populate(response, isbn) if response && response['items'].first['volumeInfo']

  rescue
    SYNC_LOG.error I18n.t('books.sync.failed.logger', provider: 'GoogleBooks', isbn: isbn)
  end

  def populate(response, isbn)
    response = response['items'].first
    volume_info = response['volumeInfo']
    metadata = {}

    # GoogleBooks does not return nil when a book is not found so we need to verify that the data returned is
    # relevant
    if volume_info['industryIdentifiers'].map { |id| id['identifier'] }.include? isbn
      metadata['google_books_id']         = response.try { |r| r['id'] }
      metadata['google_books_embeddable'] = response.try { |r| r['accessInfo']['embeddable'] }
      metadata['title']                   = volume_info.try { |v| v['title'].titlecase }
      metadata['author']                  = volume_info.try { |v| Array(v['authors']).flatten.join(', ') }
      metadata['lang']                    = volume_info.try { |v| v['language'] }
      metadata['published_date']          = volume_info.try { |v| v['publishedDate'] }
      metadata['page_count']              = volume_info.try { |v| v['pageCount'] }
    end

    self.metadata = metadata unless metadata.empty?
  end
end
