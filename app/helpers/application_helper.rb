# encoding: utf-8

module ApplicationHelper

  def lang_attr(language)
    language if language != I18n.locale.to_s
  end

  def body_dir_attr(language)
    Settings.lang.rtl_langs.include?(language) ? 'rtl' : 'ltr'
  end

  def dir_attr(language)
    if language != I18n.locale.to_s
      page_direction = Settings.lang.rtl_langs.include?(I18n.locale.to_s) ? 'rtl' : 'ltr'
      this_direction = Settings.lang.rtl_langs.include?(language) ? 'rtl' : 'ltr'
      this_direction if page_direction != this_direction
    end
  end

  def format_blockquotes(text)
    text.gsub(/^(:?quote):(.*?) ?(--? ?.*)/i, "\n<blockquote>\\2<br>\n\\3</blockquote>\n")
      .gsub(/^(:?quote):(.*$)\n? ?(--? ?.*)/i, "\n<blockquote>\\2<br>\n\\3</blockquote>\n")
      .gsub(/^(:?quote):(.*$)/i, "\n<blockquote>\\2</blockquote>\n")
  end

  def remove_instructions(text)
    text.gsub(/^(:?fork\w*):.*$/i, '')
      .gsub(/^(:?cap|alt|description|credit):.*$/i, '')
  end

  def sanitize_for_db(text)
    text = text.gsub(/<b>|<h\d>/, '<strong>')
      .gsub(%r(</b>|</h\d>), '</strong>')
    text = format_blockquotes(text)
    # OPTIMIZE: Here we need to allow a few more tags than we do on output
    #  e.g. image tags for inline image.
    text = ActionController::Base.helpers.sanitize(text, tags: Settings.notes.allowed_html_tags - ['span'],
                                                         attributes: Settings.notes.allowed_html_attributes)
    text = remove_instructions(text)
    text.gsub(/\&nbsp\;/, ' ')
      .gsub(/[\n]+/, "\n")
      .gsub(/ +/, ' ')
      .strip
  end

  def snippet(text, characters, omission = '...')
    text = ActionController::Base.helpers.sanitize(text, tags: ['h2'])
    text = text.gsub(/\[.+\]/, '')
    text = ActionController::Base.helpers.truncate(text, length: characters, separator: ' ', omission: omission)
  end

  def bookify(text, books)
    books.each do |book|
      text.gsub!(/#{ book.tag }/, (link_to book.title, book))
    end
    text
  end

  def smartify_hyphens(text)
    text.gsub(/ - ([^-^.]+) - /, "\u2013\\1\u2013")
      .gsub(/ - /, "\u2014")
  end

  def smartify_quotation_marks(text)
    # REVIEW: This needs to be language dependent
    text.gsub(/'([\d]{2})/, "\u2019\\1")
        .gsub(/(\b)'(\b)/, "\u2019")
        .gsub(/(\w)'(\w)/, "\\1\u2019\\2")
        .gsub(/(<[^>]*?)'([a-zA-Z0-9\.\-\/:_]+?)'([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3')
        .gsub(/(<[^>]*?)"([a-zA-Z0-9\.\-\/:_]+?)"([^<]*?\>)/, '\\1ATTRIBUTE_QUOTES\\2ATTRIBUTE_QUOTES\\3')
        .gsub(/'([^']+)'/, "\u2018\\1\u2019") # If quotes are not closed this would trip up.
        .gsub(/"([^"]+)"/, "\u201C\\1\u201D") # Same here.
        .gsub(/ATTRIBUTE_QUOTES/, '"')
  end

  def smartify_numbers(text)
    text.gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>')
  end

  def smartify(text)
    text = text.strip.gsub(/  /, ' ')
    text = smartify_hyphens(text)
    text = smartify_quotation_marks(text)
    text = smartify_numbers(text)
  end

  def notify(text)
    text.gsub(/( ?\[)([^\.])(.*?)( )(.*?)(\])/,
              '<span class="annotation instapaper_ignore"><span>\\2\\3\\4\\5</span></span> ')
  end

  def sanitize_for_output(text, books = [])
    text = text.strip
               .gsub(/^<strong>(.+)<\/strong>$/, '<h2>\1</h2>')
               .gsub(/^<b>(.+)<\/b>$/, '<h2>\1</h2>')
               .gsub(/^([^<].+[^>])$/, '<p>\1</p>')
               .gsub(/^<(strong|em|span)(.+)$/, '<p><\1\2</p>')
               .gsub(/^(<p> *<\/p)>$/, '')
               .gsub(/^ +$/, '')
               .gsub(/[\n]+/, "\n")
               .html_safe
  end

  def bodify(text, books = [])
    text = bookify(text, books)
    text = smartify(text)
    text = notify(text)
    text = sanitize_for_output(text)
  end
end
