# encoding: utf-8

module OutputHelper

  def blurb(headline, clean_body)
    # If the title is derived from the body, we do not include it in the blurb
    body_contains_headline = (clean_body.index(headline) == 0)
    headline = body_contains_headline ? headline : "#{ headline }: "
    start_blurb_at = body_contains_headline ? headline.length : 0
    blurb = clean_body[start_blurb_at .. clean_body.length]
              .truncate(Settings.notes.blurb_length, separator: ' ', omission: Settings.notes.blurb_omission)
              .gsub(/\W#{ Settings.notes.blurb_omission }$/, '')
    [headline, blurb]
  end

  def citation_blurb(clean_body)
    citation_text = Array(clean_body.scan(/^(.*?)\-\-/).first).first
                                    .truncate(Settings.notes.blurb_length, separator: ' ', omission: Settings.notes.blurb_omission)
                                    .gsub(/\W*#{ Settings.notes.blurb_omission }\Z/m, '')
    attribution = Array(clean_body.scan(/\-\- *(.*?)$/).first).first
    [citation_text, attribution]
  end

end
