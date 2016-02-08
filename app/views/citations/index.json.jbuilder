json.count              @total_count
json.books_count        @books_count
json.domains_count      @domains_count
json.paginates_per      NB.citations_index_per_page.to_i
json.page_number        @page_number
json.total_word_count   @word_count

json.citations          @citations, partial: 'citation', as: :citation
