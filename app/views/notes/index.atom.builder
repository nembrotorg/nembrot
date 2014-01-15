atom_feed do |feed|
  feed.title(Setting['channel.slug'])
  feed.language(Setting['advanced.locale'])
  feed.updated(@notes[0].external_updated_at) unless @notes.empty?

  @notes.each do |note|
    feed.entry(note) do |entry|
      entry.title(note.headline)
      entry.content(
        bodify(
          note.body,
          note.books,
          note.links,
          @all_interrelated_notes_and_features,
          @all_interrelated_citations,
          'citation.book.inline_annotated_html',
          'citation.link.inline_annotated_html',
          false # REVIEW: Annotations should not be excluded from atom feed
        ),
        type: 'html'
      )

      entry.author do |author|
        author.name(Setting['advanced.author'])
      end
    end
  end
end
