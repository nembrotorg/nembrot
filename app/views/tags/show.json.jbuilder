json.partial! 'tag', tag: @tag

json.notes              @notes, partial: './notes/note', as: :note
json.notes_word_count   @word_count

json.citations                @citations, partial: './citations/citation', as: :citation
json.citations_count          @citations_count
json.citations_books_count    @citations_books_count
json.citations_domains_count  @citations_domains_count

# @links = Note.link.publishable.tagged_with(@tag.name)
# @links_count = @links.size
# @links_domains_count = @links.map { |link| link.inferred_url_domain unless link.inferred_url_domain.nil? } .uniq.size

# Books
