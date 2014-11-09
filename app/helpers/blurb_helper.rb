# encoding: utf-8

module BlurbHelper

  def blurb(main_title, subtitle, clean_body, introduction = nil, blurb_length = Setting['advanced.blurb_length'].to_i, omission: Setting['advanced.blurb_omission'])

    headline = subtitle.blank? ? "#{ main_title }" : "<span>#{ main_title }: </span>#{ subtitle }"

    # If an introduction exists, use it
    # If the title is derived from the body, do not include it in the blurb
    use_body = introduction.blank? ? clean_body : "#{ introduction } #{ clean_body }"
    body_contains_headline = use_body.start_with?(headline)
    headline_ends_with_punctuation = headline.match(/\!|\?/)
    headline = body_contains_headline || headline_ends_with_punctuation ? headline : "#{ headline } "
    start_blurb_at = body_contains_headline ? headline.length : 0
    wrapped_headline = body_contains_headline ? "<span class=\"repeated-headline\">#{ headline }</span>" : ''
    blurb = "#{ wrapped_headline }#{ use_body[start_blurb_at .. use_body.length] }"
              .truncate(blurb_length, separator: ' ', omission: omission)
              .gsub(/\W#{ Setting['advanced.blurb_omission'] }$/, '')
    [headline, blurb]
  end

  def citation_blurb(clean_body, blurb_length = Setting['advanced.citation_blurb_length'].to_i)
    return [clean_body, nil] if clean_body.scan(/\-\-/).empty?
    citation_text = Array(clean_body.scan(/^(.*?)\s*\-\-/).first).first
                                    .truncate(blurb_length, separator: ' ', omission: Setting['advanced.blurb_omission'])
    attribution = Array(clean_body.scan(/\-\- *(.*?)$/).first).first
    [citation_text, attribution]
  end

end
