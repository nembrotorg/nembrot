module ApplicationHelper
  def snippet(text, wordcount)
    text = strip_tags text
    text.split[0..(wordcount-1)].join(' ') + (text.split.size > wordcount ? '...' : '')
  end

  def bodify(text)
    text.gsub(/^(.*)$/, '<p>\1</p>').html_safe
  end
end
