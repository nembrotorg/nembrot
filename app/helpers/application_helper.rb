module ApplicationHelper

  # Add html truncate gem - do teaser
  # Truncate by letters not words
  def snippet(text, wordcount)
    text = strip_tags text
    text.split[0..(wordcount-1)].join(' ') + (text.split.size > wordcount ? '...' : '') 
  end
end
