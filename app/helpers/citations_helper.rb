# encoding: utf-8

# These strings cannot be derived directly from i18n files because we need to account for missing data.

module CitationsHelper

  include FormattingHelper

  def main_details(book)
    join_text = ': ' unless book.published_city.blank?
    "#{ book.author }, <cite>#{ book.title }</cite>. #{ book.published_city }#{ join_text }#{ book.publisher } #{ book.published_date.year }."
  end

  def contributors(book)
    return nil if book.translator.blank? && book.editor.blank? && book.introducer.blank?

    matrix = [!book.translator.blank?, !book.editor.blank?, !book.introducer.blank?].join('_')

    I18n.t("citation.book.translator_editor_introducer.#{ matrix }",
        translator: book.translator,
        editor: book.editor,
        introducer: book.introducer
      )
  end

  def classification(book)
    response = "ISBN: #{ [book.isbn_10, book.isbn_13].compact.join(', ') }."
    response += " Dewey Decimal: #{ book.dewey_decimal }." unless book.dewey_decimal.blank? || book.dewey_decimal == '0' 
    response += " Library of Congress Number: #{ book.lcc_number }." unless book.lcc_number.blank?
    response
  end

  def links(book)
    response = []
    response.push link_to 'WorldCat', "http://www.worldcat.org/isbn/#{ book.isbn_13 }" unless book.isbn_13.blank?
    response.push link_to 'GoogleBooks', "http://books.google.com/books?id=#{ book.google_books_id }" unless book.google_books_id.blank?
    response.push link_to 'LibraryThing', "http://www.librarything.com/work/#{ book.library_thing_id }" unless book.library_thing_id.blank?
    response.push link_to 'OpenLibrary', "http://openlibrary.org/works/#{ book.open_library_id }" unless book.open_library_id.blank?
    response.push link_to "Full text at #{ book.full_text_url.scan(%r(http://(.*?)/))[0][0] }",
                          book.full_text_url unless book.full_text_url.blank?
    response.join(' ').html_safe
  end

  def sort_by_page_reference(list)
    list.sort_by do |citation|
      citation.clean_body.scan(/\-\-.*?p\.? *(.*)$/).flatten.first.to_i
    end
  end
end
