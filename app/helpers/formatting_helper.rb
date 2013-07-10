# encoding: utf-8

module FormattingHelper

  def format_blockquotes(text)
    text.gsub(/^.*?quote:(.*?)\n? ?-- *(.*[\d]{4}.*?)$/i,
              (render citation_partial('blockquote_with_attribution'), citation_text: "\\1", attribution: "\\2"))
        .gsub(/^.*?quote:(.*)$/i, "\n<blockquote>\\1</blockquote>\n")
  end

  def remove_instructions(text)
    text.gsub(/^(:?fork\w*):.*$/i, '')
        .gsub(/^(:?cap|alt|description|credit):.*$/i, '')
  end

  def sanitize_from_db(text)
    text = text.gsub(/<br[^>]*?>/, "\n")
               .gsub(/<b>|<h\d>/, '<strong>')
               .gsub(%r(</b>|</h\d>), '</strong>')
    # OPTIMIZE: Here we need to allow a few more tags than we do on output
    #  e.g. image tags for inline image.
    text = sanitize(text, tags: Settings.notes.allowed_html_tags - ['span'],
                                                         attributes: Settings.notes.allowed_html_attributes)
    text = format_blockquotes(text)
    text = remove_instructions(text)
  end

  def bookify(text, books, citation_partial = 'inline')
    books.each do |book|
      text.gsub!(/(<figure>\s*<blockquote)>(.*?#{ book.tag }.*?<\/figure>)/m, "\\1 cite=\"#{ url_for book }\">\\2")
      text.gsub!(/#{ book.tag }/, (render citation_partial(citation_partial), :book => book))
    end
    text
  end

  def citation_partial(partial, citation_style = Settings.styling.citation_style)
    "citations/styles/#{ citation_style }/#{ partial }"
  end

  def smartify_hyphens(text)
    text.gsub(/\s+[-\u2013]+\s+/, "\u2014") # Em-dashes for everything.
        # .gsub(/ +- +([^-^.]+) +- +/, "\u2013\\1\u2013") # Em-dashes for parentheses
        # .gsub(/(^|>| +)--?( +)/, "\u2014") # En-dashes for everything else
  end

  def smartify_quotation_marks(text)
    # TODO: This needs to be language dependent
    text.gsub(/'([\d]{2})/, "\u2019\\1")
        .gsub(/s' /, "s\u2019 ")
        .gsub(/(\b)'(\b)/, "\u2019")
        .gsub(/(\w)'(\w)/, "\\1\u2019\\2")
        .gsub(/(<[^>]*?)'([a-zA-Z0-9\.\-\/:_]+?)'([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3')
        .gsub(/(<[^>]*?)"([a-zA-Z0-9\.\-\/:_]+?)"([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3')
        .gsub(/'([^']+)'/, "\u2018\\1\u2019") # If quotes are not closed this would trip up.
        .gsub(/"([^"]+)"/, "\u201C\\1\u201D") # Same here.
        .gsub(/ATTRIBUTE_QUOTES/, '"')
  end

  def smartify_numbers(text)
    text.gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>') # Exponential
  end

  def smartify(text)
    text = smartify_hyphens(text)
    text = smartify_quotation_marks(text)
    text = smartify_numbers(text)
  end

  def notify(text)
    text.gsub(/( ?\[)([^\.])(.*?)( )(.*?)(\])/,
              '<span class="annotation instapaper_ignore"><span>\\2\\3\\4\\5</span></span> ')
  end

  def clean_whitespace(text)
    text.gsub(%r(&nbsp;), ' ')
        .gsub(/ +/m, ' ')
        .gsub(/\r\n?/, "\n")
        .gsub(/\n\n+/, "\n")
        .gsub(/^ +$/, '')
        .strip
  end

  def headerize(text)
    text.gsub(/^<strong>(.+)<\/strong>$/, '<h2>\1</h2>')
        .gsub(/^<b>(.+)<\/b>$/, '<h2>\1</h2>')
  end

  def deheaderize(text)
    text.gsub(/<strong>.*?<\/strong>/, '')
  end

  def denumber_headers(text)
    text.gsub(/(<h2>)\d+\. */, '\1')
  end

  def sectionize(text)
    text = text.split(/\*\*+/).collect { |content| "<section>#{ content }</section>" } .join unless text[/\*\*+/].blank?
    text = text.split('<h2>').collect { |content| "<section><h2>#{ content }</section>" } [1..-1].join unless text[/<h2>/].blank?
    text
  end

  def paragraphize(text)
    text.gsub(/(^|\A)([^<].+[^>])($|\Z)/, '<p>\2</p>')    # Wraps lines in <p> tags, except if they're already wrapped
        .gsub(/^<(strong|em|span)(.+)$/, '<p><\1\2</p>')  # Wraps lines that begin with strong|em|span in <p> tags
  end

  def clean_up(text)
    text.gsub!(%r(^<p> *<\/p>$), '') # Removes empty paragraphs # FIXME
    text.gsub!(/  +/m, ' ') # FIXME
    text.html_safe
  end

  def bodify(text, books = [], citation_partial = 'inline')
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = bookify(text, books, citation_partial)
    text = smartify(text)
    text = notify(text)
    text = headerize(text)
    text = paragraphize(text)
    text = denumber_headers(text)
    text = sectionize(text)
    clean_up(text)
  end

  def blurbify(text, books = {}, citation_partial = 'inline')
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = deheaderize(text)
    text = bookify(text, books, citation_partial)
    text = smartify(text)
    clean_up(text)
  end
end
