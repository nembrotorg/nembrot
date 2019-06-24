# encoding: utf-8

# These strings cannot be derived directly from i18n files because we need to account for missing data.

module CitationsHelper

  def sort_by_page_reference(list)
    list.sort_by do |citation|
      citation.clean_body.scan(/\-\-.*?p\.? *(.*)$/).flatten.first.to_i
    end
  end
end
