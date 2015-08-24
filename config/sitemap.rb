SitemapGenerator::Sitemap.default_host = "http://#{ ENV['host'] }"

SitemapGenerator::Sitemap.create do

  unless Note.publishable.listable.empty?
    add notes_path

    feature_indices = []

    Note.listable.publishable.order('feature DESC, weight ASC, feature_id DESC') .each do |note|
      if note.is_section
        add feature_path(feature: note.feature),
         lastmod: note.external_updated_at,
         priority: 0.6
      elsif note.is_feature && note.feature_id.blank?
        add feature_path(feature: note.feature),
         lastmod: note.external_updated_at,
         priority: 0.9
      elsif note.is_feature
        add feature_path(feature: note.feature, feature_id: note.feature_id),
         lastmod: note.external_updated_at,
         priority: 0.9
         feature_indices.push(note.feature)
      else
        add note_path(id: note.id),
         lastmod: note.external_updated_at,
         priority: 0.8
      end
    end

    feature_indices.uniq.each do |feature|
      add feature_path(feature),
       lastmod: Time.now,
       priority: 0.9
    end

    Note.citation.publishable.each do |citation|
      add citation_path(citation), priority: 0.9
    end

    add links_path

    unless Note.publishable.tag_counts_on(:tags).empty?
      add tags_path

      Note.publishable.tag_counts_on(:tags).each do |tag|
        add tag_path(slug: tag.slug), lastmod: Time.now
      end
    end
  end

  unless Book.cited.all.empty?
    add books_path

    Book.cited.each do |book|
      add book_path(book), lastmod: book.updated_at
    end
  end

  add pantographs_path, lastmod: Time.now
end
