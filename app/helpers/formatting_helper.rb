# encoding: utf-8

module FormattingHelper

  def bodify(text, books = [], links = [], books_citation_style = 'citation.book.inline_annotated_html', links_citation_style = 'citation.link.inline_annotated_html')
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = bookify(text, books, books_citation_style)
    text = linkify(text, links, links_citation_style)
    text = annotate(text)
    text = headerize(text)
    text = paragraphize(text)
    text = denumber_headers(text)
    text = sectionize(text)
    clean_up_via_dom(text)
  end

  def blurbify(text, books = [], links = [], books_citation_style = 'citation.book.inline_unlinked_html', links_citation_style = 'citation.link.inline_unlinked_html')
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = deheaderize(text)
    text = bookify(text, books, books_citation_style)
    text = linkify(text, links, links_citation_style)
    text = smartify(text)
    clean_up(text)
  end

  def simple_blurbify(text)
    text = clean_whitespace(text)
    text = smartify(text)
    clean_up(text)
  end

  def sanitize_from_db(text)
    text = text.gsub(/<br[^>]*?>/, "\n")
               .gsub(/<b>|<h\d>/, '<strong>')
               .gsub(%r(</b>|</h\d>), '</strong>')
    # OPTIMIZE: Here we need to allow a few more tags than we do on output
    #  e.g. image tags for inline image.
    text = sanitize(text,
                    tags: Settings.notes.allowed_html_tags - ['span'],
                    attributes: Settings.notes.allowed_html_attributes)
    text = format_blockquotes(text)
    text = remove_instructions(text)
  end

  def format_blockquotes(text)
    text.gsub(/^.*?quote:(.*?)\n? ?-- *(.*?)$/i, "\n<blockquote>\\1[\\2]</blockquote>\n")
        .gsub(/^.*?quote:(.*)$/i, "\n<blockquote>\\1</blockquote>\n")
  end

  def remove_instructions(text)
    text.gsub(/^(:?fork\w*):.*$/i, '')
        .gsub(/^(:?cap|alt|description|credit):.*$/i, '')
  end

  def clean_whitespace(text)
    text.gsub(/\n(<\/)/, '\1')
        .gsub(/&amp;/, '&')
        .gsub(/&quot;/, '"')
        .gsub(/&nbsp;/, ' ')
        .gsub(/ +/m, ' ')
        .gsub(/\r\n?/, "\n")
        .gsub(/\n\n+/, "\n")
        .gsub(/^ +$/, '')
        .strip
  end

  def bookify(text, books, citation_style)
    books.each do |book|
      text.gsub!(/(<figure>\s*<blockquote)>(.*?#{ book.tag }.*?<\/figure>)/m, "\\1 cite=\"#{ url_for book }\">\\2")
      text.gsub!(/#{ book.tag }/, t(citation_style, path: book_path(book), title: book.headline, author: book.author_sort, publisher: book.publisher, published_year: book.published_date.year))
    end
    text
  end

  def linkify(text, links, citation_style)
    # We sort the links by reverse length order of the url to avoid catching partial urls.
    links.each do |link|
      # We simplify links wrapped around themselves.
      text.gsub!(/<a href="#{ link.url }">\s*#{ link.url }\s*<\/a>/, link.url)
      # We replace linked text 
      text.gsub!(/(<a href="#{ link.url }">)(.*?)(<\/a>)/,
                 t('citation.link.inline_annotated_link_text_html',
                 link_text: '\2',
                 title: link.headline,
                 url: link.url_or_canonical_url,
                 path: link_path(link), 
                 accessed_at: (timeago_tag link.updated_at)))
      # We replace links in the body copy (look-arounds prevent us catching urls inside anchor tags).
      text.gsub!(/(?<=[^"])(#{ link.url })(?=[^"])/,
                 t(citation_style,
                 link_text: link.headline,
                 title: link.headline,
                 url: link.url_or_canonical_url,
                 path: link_path(link),
                 accessed_at: (timeago_tag link.updated_at)))
    end
    text
  end

  def annotate(text)
    annotations = text.scan(/(\[)([^\.].*? .*?)(\])/)
    if !annotations.empty?
      text.gsub!(/( *\[)([^\.].*? .*?)(\])/).each_with_index do |match, index|
        %Q(<a href="#annotation-#{ index + 1 }" id="annotation-mark-#{ index + 1 }">#{ index + 1 }</a>)
      end
      render 'notes/annotated_text', text: text, annotations: annotations
    else
      text
    end
    # text = text.gsub(/(\[)([^\.].*? .*?)(\])/, '') # Remove any nested annotations
  end

  def clean_up(text, clean_up_dom = true)
    text.gsub!(/^<p> *<\/p>$/, '') # Removes empty paragraphs # FIXME
    text = hyper_conform(text)
    text = text.gsub(/  +/m, ' ') # FIXME
               .gsub(/ ?\, ?p\./, 'p.') # Clean up page numbers
               .gsub(/"/, "\u201C") # Assume any remaining quotes are opening quotes.
               .gsub(/'/, "\u2018") # Same here
               .html_safe
  end

  def clean_up_via_dom(text)
    text = text.gsub(/ +/m, ' ')
    dom = Nokogiri::HTML(text)
    dom.css('p').find_all.each { |p| p.remove if p.content.blank? }
    # dom.css('h2').find_all.each { |h| h.content = h.content.gsub(/(<h2>)\d+\.? */, '\1') }
    dom.xpath('//text()').find_all.each do |t|
      t.content = smartify(t.content)
      t.content = hyper_conform(t.content)
    end
    # tidy = Nokogiri::XSLT File.open('vendor/tidy.xsl')
    # dom = tidy.transform(dom)

    # PATCH: Moves annotations to the end
    annotations = dom.at_css('.annotations')
    annotations.parent = dom.at_css('body') unless annotations.blank?
    dom.css('body').children.to_html.html_safe
  end

  def smartify(text)
    text = smartify_hyphens(text)
    text = smartify_quotation_marks(text)
    text = smartify_numbers(text)
  end

  def smartify_hyphens(text)
    text.gsub(/\s+[-\u2013]+\s+/, "\u2014") # Em-dashes for everything.
        # .gsub(/ +- +([^-^.]+) +- +/, "\u2013\\1\u2013") # Em-dashes for parentheses
        # .gsub(/(^|>| +)--?( +)/, "\u2014") # En-dashes for everything else
  end

  def smartify_quotation_marks(text)
    # TODO: This needs to be language dependent
    # The following assumes we are not running this on HTML text. This is not hugely concerning since for body text we
    #  run this via Nokogiri and other strings should not be marked up. (But: cite links in headers?)
    text.html_safe.gsub(/'([\d]{2})/, "\u2019\\1")
        .gsub(/s' /, "s\u2019 ")
        .gsub(/\&\#x27\;/, "\u2019")
        .gsub(/(\b)'(\b)/, "\u2019")
        .gsub(/(\w)'(\w)/, "\\1\u2019\\2")
        .gsub(/'([^']+)'/, "\u2018\\1\u2019") # If quotes are not closed this would trip up.
        .gsub(/"([^"]+)"/, "\u201C\\1\u201D") # Same here.

#        .gsub(/(<[^>]*?)'([^']+?)'([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3') # IS THIS STILL NECESSARY SINCE WE@RE DOING IT THROUGH DOM?
#        .gsub(/(<[^>]*?)"([^"]+?)"([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3')
#        .gsub(/'([^']+)'/, "\u2018\\1\u2019") # If quotes are not closed this would trip up.
#        .gsub(/"([^"]+)"/, "\u201C\\1\u201D") # Same here.
#        .gsub(/ATTRIBUTE_QUOTES/, '"')
  end

  def smartify_numbers(text)
    text.gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>') # Exponential
  end

  def headerize(text)
    text.gsub(/^<strong>(.+)<\/strong>$/, '<h2>\1</h2>')
        .gsub(/^<b>(.+)<\/b>$/, '<h2>\1</h2>')
  end

  def deheaderize(text)
    text.gsub(/<(strong|h2)>.*?<\/(strong|h2)>/, '')
  end

  def denumber_headers(text)
    text.gsub(/(<h2>)\d+\.? */, '\1')
  end

  def paragraphize(text)
    text.gsub(/(^|\A)([^<].+[^>])($|\Z)/, '<p>\2</p>')    # Wraps lines in <p> tags, except if they're already wrapped
        .gsub(/^<(strong|em|span)(.+)$/, '<p><\1\2</p>')  # Wraps lines that begin with strong|em|span in <p> tags
  end

  def sectionize(text)
    text = text.split(/\*\*+/)
               .reject(&:empty?)
               .map { |content| "<section>#{ content }</section>" }
               .join unless text[/\*\*+/].blank?
    text = text.split('<h2>')
               .reject(&:empty?)
               .map { |content| "<section><h2>#{ content }</section>" }
               .join unless text[/<h2>/].blank?
    text
  end

  def hyper_conform(text)
    text.gsub!(/\s+([\)\n\.\,\?\!])/m, '\1') # Ensure no space before certain punctuation
    text.gsub!(/([\(])\s+/m, '\1') # Ensure no space after certain elements
    text.gsub!(/([\.\,\?\!])([a-zA-Z])/m, '\1 \2') # Ensure space after certain punctuation
    # text.gsub!(/([\.\?\!])(<\/cite>)([\.\?\!])/, '\1\2') # Ensure no double punctuation after titles
    text
  end
end
