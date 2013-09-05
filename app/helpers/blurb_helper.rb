# encoding: utf-8

module BlurbHelper

  def blurb(headline, clean_body, blurb_length = Settings.notes.blurb_length)
    # If the title is derived from the body, we do not include it in the blurb
    body_contains_headline = (clean_body.index(headline) == 0)
    headline = body_contains_headline ? headline : "#{ headline }: "
    start_blurb_at = body_contains_headline ? headline.length : 0
    blurb = clean_body[start_blurb_at .. clean_body.length]
              .truncate(blurb_length, separator: ' ', omission: Settings.notes.blurb_omission)
              .gsub(/\W#{ Settings.notes.blurb_omission }$/, '')
    [headline, blurb]
  end

  def citation_blurb(clean_body, blurb_length = Settings.notes.citation_blurb_length)
    return [clean_body, nil] if clean_body.scan(/\-\-/).empty?
    citation_text = Array(clean_body.scan(/^(.*?)\-\-/).first).first
                                    .truncate(blurb_length, separator: ' ', omission: Settings.notes.blurb_omission)
                                    # .gsub(/\W*#{ Settings.notes.blurb_omission }\Z/m, '') REVIEW
    attribution = Array(clean_body.scan(/\-\- *(.*?)$/).first).first
    [citation_text, attribution]
  end

end
