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

  def current_url
    "#{ request.protocol }#{ request.host_with_port }#{ request.fullpath }"
  end

  def embeddable_url(url)
    url.gsub(/^.*youtube.*v=(.*)\b/, 'http://www.youtube.com/embed/\\1?rel=0')
       .gsub(%r(^.*vimeo.*/(\d*)\b), 'http://player.vimeo.com/video/\\1')
       .gsub(/(^.*soundcloud.*$)/, 'http://w.soundcloud.com/player/?url=\\1')
  end

  def link_to_unless_current_or_wrap(name, options = {}, html_options = {}, &block)
    link_to_unless_current name, options, html_options do
      "<span class=\"current\" data-href=\"#{ url_for(options) }\">#{ name }</span>".html_safe
    end
  end

  def qr_code_image_url(size = Settings.styling.qr_code_image_size)
    "https://chart.googleapis.com/chart?chs=#{ size }x#{ size }&cht=qr&chl=#{ current_url }"
  end

  def css_instructions(note_instructions)
    (note_instructions & Settings.styling.css_for_instructions).collect do |c|
        'ins-' + c.gsub(/__/, '').gsub(/_/, '-').downcase
    end
  end

  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end  
end
