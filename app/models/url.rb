# encoding: utf-8

class Url
  def initialize(note)
    url = note.inferred_url

    return if url.blank?

    url = resolve_url(url)

    doc = Pismo::Document.new(url)

    update_note_attributes(note, url, doc)

    URL_LOG.info "Note #{ note.id }: #{ url } processed successfully."

    rescue
      URL_LOG.error "Note #{ note.id }: #{ url } returned an error."
  end

  def self.sync_all
    Note.link.unprocessed_urls.each { |note| Url.new(note) }
  end

  private

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

  def update_note_attributes(note, url, doc)
    note.url = url
    note.url_author = doc.author
    note.url_html = ActiveSupport::Gzip.compress(doc.html)
    note.url_lede = doc.lede
    note.url_title = doc.title
    note.url_updated_at = doc.datetime
    note.url_accessed_at = Time.now
    note.url_lang = DetectLanguage.simple_detect(doc.body[0..Constant.detect_language_sample_length.to_i])
    note.keyword_list = doc.keywords.map(&:first)
    note.save!
  end
end
