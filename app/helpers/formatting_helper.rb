# encoding: utf-8

module FormattingHelper

  def bodify(text, books = [], links = [], books_citation_style = 'citation.book.inline_annotated_html', links_citation_style = 'citation.link.inline_annotated_html', annotated = true)
    return '' if text.blank?
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = bookify(text, books, books_citation_style)
    text = linkify(text, links, links_citation_style)
    text = headerize(text)
    text = sectionize(text)
    text = annotated ? annotate(text) : remove_annotations(text)
    text = paragraphize(text)
    text = denumber_headers(text)
    clean_up_via_dom(text)
  end

  def bodify_collate(source_text, target_text, source_lang, books = [], links = [], books_citation_style = 'citation.book.inline_annotated_html', links_citation_style = 'citation.link.inline_annotated_html', annotated = true)
    return '' if source_text.blank? || target_text.blank?

    source_text = sanitize_from_db(source_text)
    source_text = clean_whitespace(source_text)
    source_text = headerize(source_text)
    target_text = sectionize(target_text)
    source_text = remove_annotations(source_text)
    source_text = paragraphize(source_text)
    source_text = denumber_headers(source_text)

    target_text = sanitize_from_db(target_text)
    target_text = clean_whitespace(target_text)
    target_text = bookify(target_text, books, books_citation_style)
    target_text = linkify(target_text, links, links_citation_style)
    target_text = headerize(target_text)
    target_text = sectionize(target_text)
    target_text = annotated ? annotate(target_text) : remove_annotations(target_text)
    target_text = paragraphize(target_text)
    target_text = denumber_headers(target_text)

    clean_up_via_dom(source_text)
    clean_up_via_dom(target_text)
    collate(source_text, target_text, source_lang)
  end

  def blurbify(text, books = [], links = [], books_citation_style = 'citation.book.inline_unlinked_html', links_citation_style = 'citation.link.inline_unlinked_html')
    return '' if text.blank?
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = deheaderize(text)
    text = bookify(text, books, books_citation_style)
    text = linkify(text, links, links_citation_style)
    clean_up_via_dom(text, true)
  end

  def simple_blurbify(text)
    return '' if text.blank?
    text = clean_whitespace(text)
    text = smartify(text)
    clean_up(text)
  end

  def commentify(text)
    text = sanitize_from_db(text, ['a'])
    text = paragraphize(text)
    text = smartify(text)
    clean_up(text)
  end

  def blurbify(text, books = [], links = [], books_citation_style = 'citation.book.inline_unlinked_html', links_citation_style = 'citation.link.inline_unlinked_html')
    return '' if text.blank?
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = deheaderize(text)
    text = bookify(text, books, books_citation_style)
    text = linkify(text, links, links_citation_style)
    clean_up_via_dom(text, true)
  end

  def sanitize_from_db(text, allowed_tags = Setting['advanced.allowed_html_tags'])
    text = text.gsub(/#{ Setting['advanced.truncate_after_regexp'] }.*\Z/m, '')
               .gsub(/<br[^>]*?>/, "\n")
               .gsub(/<b>|<h\d>/, '<strong>')
               .gsub(%r(</b>|</h\d>), '</strong>')
    # OPTIMIZE: Here we need to allow a few more tags than we do on output
    #  e.g. image tags for inline image.
    text = sanitize(text,
                    tags: allowed_tags.split(/, ?| /) - ['span'],
                    attributes: Setting['advanced.allowed_html_attributes'].split(/, ?| /))
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
    # Make all local links relative
    text.gsub!(%r(^http:\/\/[a-z0-9]*\.?#{ Constant.host }), '')
    # Sort the links by reverse length order of the url to avoid catching partial urls.
    links.each do |link|
      # Simplify links wrapped around themselves.
      text.gsub!(/<a href="#{ link.url }">\s*#{ link.url }\s*<\/a>/, link.url)
      # Replace linked text 
      text.gsub!(/(<a href="#{ link.url }">)(.*?)(<\/a>)/,
                 t('citation.link.inline_annotated_link_text_html',
                 link_text: '\2',
                 title: link.headline,
                 url: link.url_or_canonical_url,
                 path: link_path(link),
                 accessed_at: (timeago_tag link.updated_at)))
      # Replace links in the body copy (look-arounds prevent us catching urls inside anchor tags).
      text.gsub!(/(?<!")(#{ link.url })(?!")/,
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
    text.gsub!(/(\[[^\]]*)\[([^\]]*)\]([^\[]*\])/, '\1\3') # Remove any nested annotations
    annotations = text.scan(/\[([^\.].*? .*?)\]/)
    if !annotations.empty?
      text.gsub!(/\s*( *\[)([^\.].*? .*?)(\])/m).each_with_index do |match, index|
        %Q(<a href="#annotation-#{ index + 1 }" id="annotation-mark-#{ index + 1 }">#{ index + 1 }</a>)
      end
      render 'notes/annotated_text', text: text, annotations: annotations.flatten
    else
      render 'notes/text', text: text
    end
  end

  def remove_annotations(text)
    text.gsub!(/(\[[^\]]*)\[([^\]]*)\]([^\[]*\])/, '\1\3') # Remove any nested annotations
    text.gsub!(/\[([^\.].*? .*?)\]/, '')
    "<section class=\"body\">#{ text.html_safe }</section>"
  end

  def clean_up(text, clean_up_dom = true)
    text.gsub!(/^<p> *<\/p>$/, '') # Removes empty paragraphs # FIXME
    text = hyper_conform(text) if Setting['style.hyper_conform'] == 'true'
    text = text.gsub(/  +/m, ' ') # FIXME
               .gsub(/ ?\, ?p\./, 'p.') # Clean up page numbers (we don't always want this) # language-dependent
               .gsub(/"/, "\u201C") # Assume any remaining quotes are opening quotes.
               .gsub(/'/, "\u2018") # Same here
               .html_safe
  end

  def clean_up_via_dom(text, unwrap_p = false)
    text = text.gsub(/ +/m, ' ')
    text = hyper_conform(text) if Setting['style.hyper_conform'] == 'true'
    dom = Nokogiri::HTML(text)
    dom = clean_up_dom(dom, unwrap_p)
    dom.css('body').children.to_html.html_safe
  end

  def clean_up_dom(dom, unwrap_p = false)
    dom.css('a, h2, header, p, section').find_all.each { |e| e.remove if e.content.blank? }
    dom.css('h2 p, cite cite').find_all.each { |e| e.replace e.inner_html }
    # dom.css('h2').find_all.each { |h| h.content = h.content.gsub(/(<h2>)\d+\.? */, '\1') }

    # Number paragraphs
    all_paragraphs = dom.css('.target').empty? ? dom.css('p') : dom.css('.target p')
    all_paragraphs.each_with_index { |e, i| e['id'] = "paragraph-#{ i + 1 }" }

    dom.xpath('//text()').find_all.each do |t|
      t.content = smartify(t.content)
      # t.content = hyper_conform(t.content)
    end
    dom = indent_dom(dom) if Constant.html.pretty_body
    unwrap_from_paragraph_tag(dom) if unwrap_p
    dom
  end

  def collate(source_text, target_text, source_lang)
    source_dom = Nokogiri::HTML(source_text)
    source_paragraphs = source_dom.css('p')

    target_dom = Nokogiri::HTML(target_text)
    target_paragraphs = target_dom.css('p')

    source_paragraphs.each_with_index do |p, i|
      # REVIEW: We can also add 'notranslate' here rather than as a metatag
      #  https://support.google.com/translate/?hl=en-GB#2641276
      p['class'] = "source"
      p['lang'] = lang_attr(source_lang)
      p['dir'] = dir_attr(source_lang) unless dir_attr(source_lang).blank?
      target_paragraph = target_paragraphs[i]
      target_paragraph['class'] = "target"
      p.replace "<div id=\"paragraph-#{ i + 1}\">#{ source_paragraphs[i].to_html }#{ target_paragraph.to_html }</div>"
    end
    dom = clean_up_dom(source_dom)
    dom.css('body').children.to_html.html_safe
  end


  def indent_dom(dom)
    tidy = Nokogiri::XSLT File.open('vendor/tidy.xsl')
    dom = tidy.transform(dom)
  end

  def unwrap_from_paragraph_tag(dom)
    e = dom.at_css('body p')
    e ? e.replace(e.inner_html) : dom
  end

  def smartify(text)
    text = smartify_hyphens(text)
    text = smartify_quotation_marks(text)
    text = smartify_numbers(text)
  end

  def smartify_hyphens(text)
    text.gsub(/\s+[\-\u2013]+\s+/, "\u2014") # Em-dashes for everything.
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
        .gsub(/'(\w|<)/, "\u2018\\1")
        .gsub(/([\w\.\,\?\!>])'/, "\\1\u2019")
        .gsub(/"(\w|<)/, "\u201C\\1")
        .gsub(/([\w\.\,\?\!>])"/, "\\1\u201D")
        .gsub(/(\u2019|\u201C)([\.\,<])/, "\\2\\1")
  end

  def smartify_numbers(text)
    text.gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>') # Exponential
  end

  def headerize(text)
    text.gsub(/^<strong>(.+)<\/strong>$/, '<header><h2>\1</h2></header>')
        .gsub(/^<b>(.+)<\/b>$/, '<header><h2>\1</h2></header>')
  end

  def deheaderize(text)
    text.gsub(/<(strong|h2)>.*?<\/(strong|h2)>/, '')
  end

  def denumber_headers(text)
    text.gsub(/(<h2>)\d+\.? */, '\1')
  end

  def paragraphize(text)
    text.gsub(/^\s*(<section[^>]*>)\s*([^<].+[^>])\s*(<\/section>)\s*$/, '\1<p>\2</p>\3')
        .gsub(/^\s*(<section[^>]*>)\s*([^<].+[^>])\s*$/, '\1<p>\2</p>')
        .gsub(/^ *([^<].+[^>])\s*(<\/section>)\s*$/, '<p>\1</p>\2')
        .gsub(/^\s*([^<].+[^>])\s*$/, '<p>\1</p>')    # Wraps lines in <p> tags, except if they're already wrapped
        .gsub(/^<(strong|em|span|a)(.+)$/, '<p><\1\2</p>')  # Wraps lines that begin with strong|em|span|a in <p> tags
        .gsub(/^(.+)(<\/)(strong|em|span|a)>$/, '<p>\1\2\3></p>')  # ... and ones that end with those tags.
  end

  def sectionize(text)
    text = text.split(/<p>(\*\*+|\-\-+)<\/p>|<hr ?\/?>/)
               .reject(&:empty?)
               .map { |content| "<section>#{ content }</section>" }
               .join unless text[/<p>(\*\*+|\-\-+)<\/p>|<hr ?\/?>/].blank?
    text = text.split('<header>')
               .reject(&:empty?)
               .map { |content| "<section><header>#{ content }</section>" }
               .join unless text[/<h2>/].blank?
    text
  end

  def hyper_conform(text)
    text.gsub(/\s+([\)\n\.\,\?\!])/m, '\1') # Ensure no space before certain punctuation
        .gsub(/([\(])\s+/m, '\1') # Ensure no space after certain elements
        .gsub(/([\.\,\?\!])([a-zA-Z])/m, '\1 \2') # Ensure space after certain punctuation
        .gsub(/([[:upper:]]{3,})/, '<abbr>\1</abbr>') # Wrap all-caps in <abbr>
        .gsub(/\b([A-Z]{1})\./, '\1') # Wrap all-caps in <abbr>
        .gsub(/(<p>|<li>)([[:lower:]])/) { "#{ $1 }#{ $2.upcase }" } # Always start with a capital
        .gsub(/(\.|\?|\!) ([[:lower:]])/) { "#{ $1 }#{ $2.upcase }" } # Always start with a capital
        .gsub(/(\w)(<\/p>|<\/li>)/, '\1.\2') # Always end with punctuation -- What about verse? __VERSE ? (& lists?)
        .gsub(/\s+(<a href=\"#annotation-)/m, '\1')
        .gsub(/ *(<a href=\"#annotation-.*?<\/a>) *([\.\,\;\?\!])/, '\2\1')
        .gsub(/([\.\?\!])(<\/cite>)([\.\?\!])/, '\1\2') # Ensure no double punctuation after titles
        .html_safe
  end
end
