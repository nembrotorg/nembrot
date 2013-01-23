module ApplicationHelper
  def lang_attr(language)
    if language != I18n.locale.to_s
      language
    end
  end

  def body_dir_attr(language)
    if Settings.lang.rtl_langs.include?(language)
      'rtl'
    end
  end

  def dir_attr(language)
    if language != I18n.locale.to_s
      Settings.lang.rtl_langs.include?(language) ? 'rtl' : 'ltr'
    end
  end

  def snippet(text, wordcount)
    text = strip_tags text
    text.split[0..(wordcount-1)].join(' ') + (text.split.size > wordcount ? '...' : '')
  end

  def bodify(text)
    text.gsub(/^(.*)$/, '<p>\1</p>').html_safe
  end
end
