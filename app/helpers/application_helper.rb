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

  def snippet(text, characters, omission = '...')
    text = ActionController::Base.helpers.sanitize(text, tags: ['h2'])
    text = text.gsub(/\[.+\]/, '')
    text = ActionController::Base.helpers.truncate(text, length: characters, separator: ' ', omission: omission)
  end

  def smartify(text)
    text.gsub(/ - ([^-^.]+) - /, '\u2013\\1\u2013')
        .gsub(/  /, ' ')
        .gsub(/ - /, '\u2014')
        .gsub(/'([\d{2}])/, '\u2019\\1')
        .gsub(/(\b)'(\b)/, '\u2019')
        .gsub(/(\w)'(\w)/, '\\1\u2019\\2')
        .gsub(/'([^']+)'/, '\u2018\\1\u2019')
        .gsub(/"([^"]+)"/, '\u201C\\1\u201D')
        .gsub(/(<[^>]*)\u201C([a-zA-Z0-9\.\-\/:_]+?)\u201D([^<]*\>)/, '\\1\'\\2\'\\3')
        .gsub(/(\d)\^([\d\,\.]+)/, '\\1<sup>\\2</sup>')
  end

  def notify(text)
    text
      .gsub(/ ?\[/, '<span class="annotation instapaper_ignore"><span>')
      .gsub(/\]/, '</span></span> ')
  end

  def bodify(text, books = [])
    text = bookify(text, books)
    text = smartify(text)
    text = notify(text)
    text = text.strip
               .gsub(/[\n]+/, '\n')
               .gsub(/^([^<].+[^>])$/, '<p>\1</p>')
               .gsub(/^<strong>(.+)<\/strong>$/, '<h2>\1</h2>')
               .gsub(/^<b>(.+)<\/b>$/, '<h2>\1</h2>')
               .gsub(/^(<p> *<\/p)>$/, '')
               .gsub(/^ +$/, '')
               .html_safe
  end

  def bookify(text, books)
    books.each do |book|
      text.gsub!(/#{ book.tag }/, (link_to book.headline, book))
    end
    text
  end
end
