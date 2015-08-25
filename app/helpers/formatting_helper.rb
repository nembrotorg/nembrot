# encoding: utf-8

# REVIEW: All these functions should be moved to Nokogiri

module FormattingHelper
  def bodify(text, books = [], books_citation_style = 'citation.book.inline_annotated_html', links_citation_style = 'citation.link.inline_annotated_html', annotated = true)
    return '' if text.blank?
    # REVIEW: Add settings condition
    text = related_notify(text)
    text = related_citationify(text)
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = bookify(text, books, books_citation_style) if NB.books_section == 'true'
    text = relativize(text)
    text = headerize(text)
    text = sectionize(text)
    text = paragraphize(text)
    text = annotated ? annotate(text) : remove_annotations(text)
    text = denumber_headers(text)
    clean_up_via_dom(text, false, true)
  end

  def bodify_collate(source_text, target_text, source_lang, books = [], books_citation_style = 'citation.book.inline_annotated_html', links_citation_style = 'citation.link.inline_annotated_html', annotated = true)
    return '' if source_text.blank? || target_text.blank?
    source_text = sanitize_from_db(source_text)
    source_text = clean_whitespace(source_text)
    source_text = headerize(source_text)
    source_text = sectionize(source_text)
    source_text = paragraphize(source_text)
    source_text = remove_annotations(source_text)
    source_text = denumber_headers(source_text)
    source_text = clean_up_via_dom(source_text)
    # REVIEW: Add settings condition
    target_text = related_notify(target_text)
    target_text = related_citationify(target_text)
    target_text = sanitize_from_db(target_text)
    target_text = clean_whitespace(target_text)
    target_text = bookify(target_text, books, books_citation_style) if NB.books_section == 'true'
    target_text = relativize(target_text)
    target_text = headerize(target_text)
    target_text = sectionize(target_text)
    target_text = paragraphize(target_text)
    target_text = annotated ? annotate(target_text) : remove_annotations(target_text)
    target_text = denumber_headers(target_text)
    target_text = clean_up_via_dom(target_text)

    collate(source_text, target_text, source_lang)
  end

  def blurbify(text, books = [], books_citation_style = 'citation.book.inline_unlinked_html', links_citation_style = 'citation.link.inline_unlinked_html', strip_tags = true)
    return '' if text.blank?
    # REVIEW: Add settings condition
    text = related_notify(text, true)
    text = related_citationify(text)
    text = sanitize_from_db(text)
    text = clean_whitespace(text)
    text = deheaderize(text)
    text = bookify(text, books, books_citation_style) if NB.books_section == 'true'
    text = relativize(text)
    text = clean_up_via_dom(text, true)
    text = strip_tags(text) if strip_tags
    text
  end

  def sanitize_by_settings(text, allowed_tags = NB.allowed_html_tags)
    sanitize(text,
      tags: allowed_tags.split(/, ?| /) - ['span'], # REVIEW: Why remove <span> here?
      attributes: NB.allowed_html_attributes.split(/, ?| /))
  end

  def simple_blurbify_link(text, allowed_tags = NB.allowed_html_tags)
    text = text.gsub(/ *\|.*$/, '').gsub(/ *—.*$/, '')
    simple_blurbify(text, allowed_tags)
  end

  def simple_blurbify(text, allowed_tags = NB.allowed_html_tags)
    return '' if text.blank?
    text = sanitize(text, { tags: allowed_tags.split(/, ?| /) + ['span'] }) # REVIEW: Why add <span> here? For Feature titles
    text = clean_whitespace(text)
    text = smartify_punctuation(text)
    # FIXME: Clean up smart quotes inside tags
    text = text.gsub(/<([^<]*)("|“|\u201C|\u201D)([^>]*)("|“|\u201C|\u201D)([^>]*)>/, "<\\1\"\\3\"\\5>").html_safe
    # clean_up(text)
  end

  def commentify(text)
    text = sanitize_from_db(text, ['a'])
    text = paragraphize(text)
    text = smartify_punctuation(text)
    # FIXME: Clean up smart quotes inside tags
    text = text.gsub(/<([^<]*)("|“|\u201C|\u201D)([^>]*)("|“|\u201C|\u201D)([^>]*)>/, "<\\1\"\\3\"\\5>").html_safe
    # clean_up(text)
  end

  # REVIEW: Overkill with allowed_tags = NB.allowed_html_tags
  def sanitize_from_db(text, allowed_tags = NB.allowed_html_tags)
    text = sanitize_from_evernote(text)
    text = text.gsub(/#{ NB.truncate_after_regexp }.*\Z/m, '')
           .gsub(/<br[^>]*?>/, "\n")
           .gsub(/<b>|<h\d>/, '<strong>')
           .gsub(%r{</b>|</h\d>}, '</strong>')
    # OPTIMIZE: Here we need to allow a few more tags than we do on output
    #  e.g. image tags for inline image.
    text = sanitize_by_settings(text, allowed_tags)
    text = format_blockquotes(text)
    text = format_code(text)
    text = remove_instructions(text)
  end

  def sanitize_from_evernote(text)
    # Make all local links relative and
    #  Evernote expects all paragraphs to be wrapped in divs
    #  See: http://dev.evernote.com/doc/articles/enml.php#plaintext
    text = text.gsub(/\n|\r/, '')
           .gsub(%r{^http:\/\/[a-z0-9]*\.?#{ NB.host }}, '')
           .gsub(/(<div style="padding\-left: 30px;">)(.*?)(<\/div>)/mi, "<div>{quote:\n\\2\n}</div>")
           .gsub(/(<div style="padding\-left: 30px;">)(.*?)(<\/div>)/i, "<div>{quote:\\2}</div>")
           .gsub(/(<p>|<div)/i, "\n\\1")
           .gsub(/(<\/p>|<\/div>)/i, "\\1\n")
    #.gsub(/(<aside|<blockquote|<br|<div|<fig|<p|<ul|<ol|<li|<nav|<section|<table)/i, "\n\\1")
    #.gsub(/(<\/aside>|<\/blockquote>|<\/br>|<\/div>|<\/figure>|<\/p>|<\/figcaption>|<\/ul>|<\/ol>|<\/li>|<\/nav>|<\/section>|<\/table>)/i, "\\1\n")
    text = "\n#{ text }\n"
  end

  def format_blockquotes(text)
    text.gsub(/{\s*quote:([^}]*?)\n? ?-- *([^}]*?)\s*}/i, "\n<blockquote>\\1[\\2]</blockquote>\n")
      .gsub(/{\s*quote:([^}]*?)\n? ?-- *([^}]*?)\s*}/mi, "\n<blockquote>\n\\1[\\2]\n</blockquote>\n")
      .gsub(/{\s*quote:([^}]*?)\s*}/i, "\n<blockquote>\\1</blockquote>\n")
      .gsub(/{\s*quote:([^}]*?)\s*}/mi, "\n<blockquote>\n\\1\n</blockquote>\n")
      .gsub(/\s*quote:([^}]*?)\n? ?-- *([^\}]*?)\s*/i, "\n<blockquote>\\1[\\2]</blockquote>\n")
      .gsub(/\s*quote:([^}]*?)\s*/i, "\n<blockquote>\\1</blockquote>\n")
  end

  def format_code(text)
    text.gsub(/{\s*code:([^}]*?)\n? ?-- *([^}]*?)\s*}/i, "\n<pre><code>\\1[\\2]</code></pre>\n")
      .gsub(/{\s*code:([^}]*?)\n? ?-- *([^}]*?)\s*}/mi, "\n<pre><code>\n\\1[\\2]\n</code></pre>\n")
      .gsub(/{\s*code:([^}]*?)\s*}/i, "\n<pre><code>\\1</code></pre>\n")
      .gsub(/{\s*code:([^}]*?)\s*}/mi, "\n<pre><code>\n\\1\n</code></pre>\n")
      .gsub(/\s*code:([^}]*?)\n? ?-- *([^\}]*?)\s*/i, "\n<pre><code>\\1[\\2]</code></pre>\n")
      .gsub(/\s*code:([^}]*?)\s*/i, "\n<pre><code>\\1</code></pre>\n")
  end

  def remove_instructions(text)
    text.gsub(/\{fork:.*\}/i, '')
      .gsub(/\{(cap|alt|description|credit|intro):.*\}/i, '')
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

  def relativize(text)
    # Make all local links relative
    text.gsub(/(<a href=")http:\/\/#{ NB.host }([^"]*?"[^>]*?>)/, "\\1\\2")
  end

  def related_notify(text, strip_tags = false)
    # REVIEW: Do this with note titles?
    note_ids = mentioned_notes(text)
    related_notes = Note.related_notes(note_ids)
    related_notes.each do |note|
      body = strip_tags ? sanitize(note.clean_body) : note.body
      text.gsub!(/\{link:? *#{ note_or_feature_path(note) }\}/, link_to(note.headline, note_path(note)))
      text.gsub!(/\{link:? *#{ note.headline }\}/, link_to(note.headline, note_path(note)))
      text.gsub!(/\{blurb:? *#{ note_or_feature_path(note) }\}/, (render 'shared/note_blurb', note: note))
      text.gsub!(/\{blurb:? *#{ note.headline }\}/, (render 'shared/note_blurb', note: note))
      text.gsub!(/\{text:? *#{ note_or_feature_path(note) }\}/, "#{ body }\n[#{ link_to(note.headline, note_path(note)) }]")
      text.gsub!(/\{text:? *#{ note.headline }\}/, "#{ body }\n[#{ link_to(note.headline, note_path(note)) }]")
    end
    # text.gsub!(/\{[^\}]*?\}/, '') # Clean up faulty references
    text = strip_tags(text) if strip_tags
    text
  end

  def mentioned_notes(text)
    text.scan(/\{ *(link|blurb|text)\:? *\/texts\/([\d]+) *\}/).map(&:last).flatten
  end

  def related_citationify(text, strip_tags = false)
    citation_ids = mentioned_citations(text)
    related_citations = Note.related_citations(citation_ids)
    related_citations.each do |citation|
      body = strip_tags ? sanitize(citation.clean_body) : citation.body
      text.gsub!(/\{link:? *#{ citation_path(citation) }\}/, link_to(citation.headline, citation_path(citation)))
      text.gsub!(/\{blurb:? *#{ citation_path(citation) }\}/, body)
      text.gsub!(/\{text:? *#{ citation_path(citation) }\}/, "#{ body }\n") # REVIEW: Also link to citation?
    end
    # text.gsub!(/\{[^\}]*?\}/, '') # Clean up faulty references
    text = strip_tags(text) if strip_tags
    text
  end

  def mentioned_citations(text)
    text.scan(/\{ *(link|blurb|text)\:? *\/citations\/([\d]+) *\}/).map(&:last).flatten
  end

  def annotate(text)
    text.gsub!(/(\[[^\]]*)\[([^\]]*)\]([^\[]*\])/, '\1\3') # Remove any nested annotations
    annotations = text.scan(/\[([^\.].*? .*?)\]/)
    if !annotations.empty?
      text.gsub!(/\s*( *\[)([^\.].*? .*?)(\])/m).each_with_index do |_match, index|
        %(<a href="#annotation-#{ index + 1 }" id="annotation-mark-#{ index + 1 }">#{ index + 1 }</a>)
      end
      render 'notes/annotated_text.html', text: text, annotations: annotations.flatten
    else
      render 'notes/text.html', text: text
    end
  end

  def remove_annotations(text)
    text.gsub!(/(\[[^\]]*)\[([^\]]*)\]([^\[]*\])/, '\1\3') # Remove any nested annotations
    text.gsub!(/\[([^\.].*? .*?)\]/, '')
    "<section class=\"body\">#{ text.html_safe }</section>"
  end

  def clean_up(text, _clean_up_dom = true)
    # REVIEW: These operations should not be necessary!
    # .gsub(/(<[^>"]*?)[\u201C|\u201D]([^<"]*?>)/, '\1"\2') # FIXME: This is for links in credits but it should not be necessary
    text.gsub!(/^<p>\s*<\/p>$/m, '') # Removes empty paragraphs # FIXME
    text = hyper_conform(text) if NB.hyper_conform == 'true'
    text = text.gsub(/  +/m, ' ') # FIXME
           .gsub(/ ?\, ?p\./, 'p.') # Clean up page numbers (we don't always want this) # language-dependent
           .gsub(/"/, "\u201C") # Assume any remaining quotes are opening quotes.
           .gsub(/'/, "\u2018") # Same here
           .html_safe
  end

  def clean_up_via_dom(text, unwrap_p = false, number_paragraphs = false)
    text = text.gsub(/ +/m, ' ')
    text = hyper_conform(text) if NB.hyper_conform == 'true'
    text = smartify_numbers(text)
    dom = Nokogiri::HTML(text)
    dom = clean_up_dom(dom, unwrap_p, number_paragraphs)
    dom.css('body').children.to_html.html_safe
  end

  def clean_up_dom(dom, unwrap_p = false, number_paragraphs = false)
    dom.css('a, h2, header, p, section').find_all.each { |e| e.remove if e.content.blank? } # Remove empty tags
    dom.css('h2 p, cite cite, p section, p header, p p, p h2, blockquote blockquote').find_all.each { |e| e.replace e.inner_html } # Sanitise wrong nesting
    dom.css('h2').find_all.each { |h| h.content = h.content.gsub(/(<h2>)\d+\.? */, '\1') }  # Denumberise headers

    # Number paragraphs
    dom.css('p').each_with_index { |e, i| e['id'] = "paragraph-#{ i + 1 }" } if number_paragraphs

    dom.xpath('//text()').find_all.each do |t|
      t.content = smartify_punctuation(t.content)
      # t.content = t.content.strip ... we only want to strip from the beginning of files
      # t.content = hyper_conform(t.content)
    end
    dom = indent_dom(dom) if NB.html_pretty_body == 'true'
    unwrap_from_paragraph_tag(dom) if unwrap_p
    dom
  end

  def collate(source_text, target_text, source_lang)
    source_dom = Nokogiri::HTML(source_text)
    source_paragraphs = source_dom.css('p')

    target_dom = Nokogiri::HTML(target_text)
    target_paragraphs = target_dom.css('p')

    annotations = target_dom.css('.annotations')

    source_paragraphs.each_with_index do |p, _i|
      # REVIEW: We can also add 'notranslate' here rather than as a metatag
      #  https://support.google.com/translate/?hl=en-GB#2641276
      p['class'] = 'source'
      p['lang'] = lang_attr(source_lang)
      p['dir'] = dir_attr(source_lang) unless dir_attr(source_lang).blank?
    end

    target_paragraphs.each_with_index do |p, i|
      p['class'] = 'target'
      source_paragraph_html = source_paragraphs[i].nil? ? '<!-- -->' : source_paragraphs[i].to_html
      target_paragraph_html = target_paragraphs[i].nil? ? '<!-- -->' : target_paragraphs[i].to_html
      p.replace "<div id=\paragraph-#{ i+1 }\>#{ source_paragraph_html }#{ target_paragraph_html }</div>"
    end

    dom = clean_up_dom(target_dom)
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

  def smartify_punctuation(text)
    text = smartify_hyphens(text)
    text = smartify_quotation_marks(text)
    text = force_double_quotes(text) if NB.force_double_quotes == 'true'
  end

  def smartify_hyphens(text)
    text.gsub(/\s+[\-\u2013]+\s+/, "\u2014") # Em-dashes for everything.
  end

  def smartify_hyphens_mixed(text)
    text.gsub(/ +- +([^-^.]+) +- +/, "\u2013\\1\u2013") # Em-dashes for parentheses
      .gsub(/(^|>| +)--?( +)/, "\u2014") # En-dashes for everything else
  end

  def smartify_quotation_marks(text)
    # TODO: This needs to be language dependent
    # The following assumes we are not running this on HTML text. This is not hugely concerning since for body text we
    #  run this via Nokogiri and other strings should not be marked up. (But: cite links in headers?)
    text.gsub(/'([\d]{2})/, "\u2019\\1")
      .gsub(/\&lsquo\;/, "\u2018")
      .gsub(/\&rsquo\;/, "\u2019")
      .gsub(/\&\#x27\;/, "\u2019")
      .gsub(/s' /, "s\u2019 ")
      .gsub(/(\b)'(\b)/, "\u2019")
      .gsub(/(\w)'(\w)/, "\\1\u2019\\2")
      .gsub(/'(\w|<)/, "\u2018\\1")
      .gsub(/([\w\.\,\?\!>])'/, "\\1\u2019")
      .gsub(/\&\#39\;/, '"')
      .gsub(/"(\w|<)/, "\u201C\\1")
      .gsub(/([\w\.\,\?\!>])"/, "\\1\u201D")
      .gsub(/(\u2019|\u201C)([\.\,<])/, '\\2\\1')
  end

  def force_double_quotes(text)
    text.gsub(/'(\w|<)(.*?)([\w\.\,\?\!>])'(\W)/, "\u201C\\1\\2\\3\u201D\\4")
      .gsub(/\u2018(\w|<)(.*?)([\w\.\,\?\!>])\u2019(\W)/, "\u201C\\1\\2\\3\u201D\\4")
  end

  def smartify_numbers(text)
    text.gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>') # Exponential
  end

  def headerize(text)
    text.gsub(/^\s*<strong>(.+?)<\/strong>\s*$/m, '<header><h2>\1</h2></header>')
      .gsub(/^\s*<p><strong>(.+?)<\/strong><\/p>\s*$/m, '<header><h2>\1</h2></header>')
      .gsub(/^\s*<b>(.+?)<\/b>\s*$/m, '<header><h2>\1</h2></header>')
      .gsub(/^\s*<b>(.+?)<\/b>\s*$/m, '<header><h2>\1</h2></header>')
  end

  def deheaderize(text)
    text.gsub(/<(strong|h2)>.*?<\/(strong|h2)>/m, '')
  end

  def denumber_headers(text)
    text.gsub(/(<h2>)\d+\.? */, '\1')
  end

  def paragraphize(text)
    text.gsub(/^\s*([^<].*?)\s*$/, "<p>\\1</p>") # Wrap lines that do not begin with a tag
      .gsub(/^\s*(<a|<del|<em|<i|<ins|<strong)(.*?)\s*$/, "<p>\\1\\2</p>") # Wrap lines that begin with inline tags
      .gsub(/^\s*(.*?)(a>|del>|em>|i>|ins>|strong>)\s*$/, "<p>\\1\\2</p>") # Wrap lines that end with inline tags
  end

  def sectionize(text)
    text = text.split(/^\*\*\*+$|^\-\-\-+$|<hr ?\/?>/)
           .reject(&:empty?)
           .map { |content| "<section>\n#{ content }\n</section>" }
           .join unless text[/^\s*(\*\*+|\-\-+)|<hr ?\/?>\s*$/].blank?
    text = text.split(/(?=<header)/)
           .reject(&:empty?)
           .map { |content| "<section>\n#{ content }\n</section>" } # n#{ content.include? '<h2' ? '<header>' : '' }\
           .join unless text[/<header/].blank?
    text
  end

  def hyper_conform(text)
    text.gsub(/\s+([\)\n\.\,\?\!])/m, '\1') # Ensure no space before certain punctuation
      .gsub(/([\(])\s+/m, '\1') # Ensure no space after certain elements
      .gsub(/([\.\,\?\!])([a-zA-Z])/m, '\1 \2') # Ensure space after certain punctuation
      .gsub(/([[:upper:]]{3,})/, '<abbr>\1</abbr>') # Wrap all-caps in <abbr>
      .gsub(/\b([A-Z]{1})\./, '\1') # Wrap all-caps in <abbr>
      .gsub(/(<p>|<li>)([[:lower:]])/) { "#{ Regexp.last_match[1] }#{ Regexp.last_match[2].upcase }" } # Always start with a capital
      .gsub(/(\.|\?|\!) ([[:lower:]])/) { "#{ Regexp.last_match[1] }#{ Regexp.last_match[2].upcase }" } # Always start with a capital
      .gsub(/(\w)(<\/p>|<\/li>)/, '\1.\2') # Always end with punctuation -- What about verse? __VERSE ? (& lists?)
      .gsub(/\s+(<a href=\"#annotation-)/m, '\1')
      .gsub(/ *(<a href=\"#annotation-.*?<\/a>) *([\.\,\;\?\!])/, '\2\1')
      .gsub(/([\.\?\!])(<\/cite>)([\.\?\!])/, '\1\2') # Ensure no double punctuation after titles
      .html_safe
  end
end
