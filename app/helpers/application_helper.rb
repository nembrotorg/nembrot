# encoding: utf-8

module ApplicationHelper
  include CacheHelper
  include FollowUrlsHelper

  def lang_attr(language)
    language if language != I18n.locale.to_s
  end

  def body_dir_attr(language)
    NB.rtl_langs.split(/, ?| /).include?(language) ? 'rtl' : 'ltr'
  end

  def dir_attr(language)
    if language != I18n.locale.to_s
      page_direction = NB.rtl_langs.split(/, ?| /).include?(I18n.locale.to_s) ? 'rtl' : 'ltr'
      this_direction = NB.rtl_langs.split(/, ?| /).include?(language) ? 'rtl' : 'ltr'
      this_direction if page_direction != this_direction
    end
  end

  def current_url
    "#{ request.protocol }#{ request.host_with_port }#{ request.fullpath }"
  end

  def embeddable_url(url)
    url.gsub(/^.*youtube.*v=(.*)\b/, 'http://www.youtube.com/embed/\\1?rel=0')
      .gsub(/^.*youtube.*list=(.*)\b/, 'http://www.youtube.com/embed/videoseries?list=\\1&rel=0')
      .gsub(%r{^.*vimeo.*/(\d*)\b}, 'http://player.vimeo.com/video/\\1')
      .gsub(/(^.*soundcloud.*$)/, 'http://w.soundcloud.com/player/?url=\\1')
      .gsub(/(^.*spotify.*$)/, 'https://embed.spotify.com/?uri=\\1')
  end

  def link_to_unless_or_wrap(condition, name, options = {}, html_options = {})
    link_to_unless condition, name, options, html_options do
      "<span class=\"current\" data-href=\"#{ url_for(options) }\">#{ name }</span>".html_safe
    end
  end

  def link_to_unless_current_or_wrap(name, options = {}, html_options = {})
    link_to_unless_or_wrap current_page?(options), name, options, html_options
  end

  def css_instructions(note_instructions)
    # If an instruction is listed in css_for_instructions, it is written out as a css class
    # TODO: Test for this
    (note_instructions & NB.css_for_instructions.split(/, ?| /)).map do |c|
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

  def note_or_feature_path(note)
    note.has_instruction?('feature') ? feature_path(note.feature, note.feature_id) : note_path(note)
  end

  def note_or_feature_index_path(note)
    # Be careful that feature is not repeated
    #  Imitate for home blurbs
    note.has_instruction?('feature') ? feature_path(feature: note.feature) : note_path(note)
  end

  def site_title_from_url(url)
    url.gsub(/.*tumblr.*/, 'Tumblr')
      .gsub(/plus\.google/, 'Google+')
      .gsub(/^www\./, '')
      .gsub(/^([^\.]*).*$/, '\1')
      .titlecase
  end
end
