# encoding: utf-8

class Url

  def initialize(note)

    url = note.inferred_url

    return if url.blank?

    url = resolve_url(url)

    doc = Pismo::Document.new(url)

    note.url = url
    note.url_author = doc.author
    note.url_html = ActiveSupport::Gzip.compress(doc.html)
    note.url_lede = doc.lede
    note.url_title = doc.title
    note.url_updated_at = doc.datetime
    note.url_accessed_at = Time.now
    note.keyword_list = doc.keywords.map { |k| k.first }

    note.save!

    URL_LOG.info "Note #{ note.id }: #{ url } processed successfully."

    #rescue
    #  URL_LOG.error "Note #{ note.id }: #{ url } returned an error."
  end

  def resolve_url(url)
    # REVIEW: This makes an extra call and could be avoided (by forking gem)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host)
    return url if uri.path.blank?
    response = http.get(uri.path)
    response.header['location']
    #rescue
    #  return url
  end

end
