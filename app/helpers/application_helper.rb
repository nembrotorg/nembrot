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

end
