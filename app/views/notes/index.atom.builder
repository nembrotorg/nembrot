atom_feed do |feed|
  feed.title(NB.name)
  feed.language(NB.locale)
  feed.updated(@notes[0].external_updated_at) unless @notes.empty?

  cache [cache_buster(1), @notes] do
    @notes.each do |note|
      feed.entry(note) do |entry|
        entry.title(note.headline)
        entry.content(
          bodify(
            note.body,
            note.books,
            'citation.book.inline_annotated_html',
            'citation.link.inline_annotated_html',
            false # REVIEW: Annotations should not be excluded from atom feed
          ),
          type: 'html'
        )

        entry.author do |author|
          author.name(NB.author)
        end
      end
    end
  end
end
