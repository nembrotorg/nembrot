module ApplicationHelper

  # Add html truncate gem - do teaser
  # Truncate by letters not words
  def snippet(text, wordcount)
    text = strip_tags text
    text.split[0..(wordcount-1)].join(' ') + (text.split.size > wordcount ? '...' : '') 
  end

  def bodify(text)
    (sanitize text, :tags => %w(a ul ol li), :attributes => %w(href))
      .gsub(/^.*DOCTYPE.*>/, '')
      .gsub(/^(\w*)$/, '')
      .gsub(/^(.*)$/, '<p>\1</p>')
      .html_safe
  end
end
