# encoding: utf-8

class LinkRequest

  attr_accessor :metadata, :nokogiri_dom

  def initialize(url)

    self.nokogiri_dom = Nokogiri::HTML(open(url))

    populate unless nokogiri_dom.blank?

  rescue OpenURI::HTTPError => error
    SYNC_LOG.error "404 error!!! #{ url }"
  rescue
    SYNC_LOG.error "Other error #{ url }"
  end

  def quick_css(css_query)
    selector = nokogiri_dom.css(css_query)
    case css_query.gsub(/\w+/).first
    when 'meta'
      return selector.first['content']
    when 'link'
      return selector.first['href']
    when 'html'
      return selector.first['lang']
    else
      return selector.first.text
    end if selector.first
  end

  def populate
    metadata = {}

    metadata['author']           = quick_css('meta[name=author]')
    metadata['canonical_url']    = quick_css('link[rel=canonical]')
    metadata['lang']             = quick_css('html')
    metadata['modified']         = quick_css('meta[http-equiv=last-modified]')
    metadata['publisher']        = quick_css('meta[name=publisher]')

    found_title = quick_css('title')
    if found_title
      full_title_parsed = found_title.split(/ - |\|/)
      metadata['title']         = full_title_parsed.first
      metadata['website_name']  = full_title_parsed.last unless full_title_parsed.size == 1
    end

    found_geo = quick_css('.geo')
    if found_geo
      geo_parsed = found_geo.split(/; ?/)
      metadata['latitude']    = geo_parsed.first
      metadata['longitude']   = geo_parsed.second
    end

    self.metadata = metadata unless metadata.empty?
    SYNC_LOG.info "Fetched #{ url }"
  end
end
