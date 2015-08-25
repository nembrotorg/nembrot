json.count              @total_count
json.paginates_per      NB.notes_index_per_page.to_i
json.page_number        @page_number
json.total_word_count   @word_count

json.texts              @notes, partial: 'note', as: :note
