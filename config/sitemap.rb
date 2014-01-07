SitemapGenerator::Sitemap.default_host = "http://#{ Constant.host }"

SitemapGenerator::Sitemap.create do

  unless Book.cited.empty?
    add books_path

    Book.cited.each do |book|
      add book_path(book), lastmod: book.updated_at
    end
  end

  unless Link.publishable.empty?
    add links_path

    Link.publishable.each do |link|
      add link_path(link), lastmod: link.updated_at
    end
  end

  unless Note.publishable.listable.empty?
    add notes_path

    Note.publishable.listable.each do |note|
      # REVIEW: Unable to include ApplicationHelper here
      # Feaure and section indices are added later
      if note.feature.nil? || !note.feature_id.nil?
        add (note.has_instruction?('feature') ? feature_path(note.feature, note.feature_id) : note_path(note)), 
         lastmod: note.external_updated_at,
         priority: (note.is_feature? && !note.is_section?) ? 0.8 : 0.7
      end
    end

    Note.features.each do |feature|
      add feature_path(feature: feature), priority: 0.9
    end

    # REVIEW: Lastmod here becomes more recent than anything else
    Note.sections.each do |section|
      add feature_path(feature: section)
    end
  end

  unless Note.publishable.tag_counts_on(:tags).empty?
    add tags_path

    Note.publishable.tag_counts_on(:tags).each do |tag|
      add tag_path(tag), lastmod: Time.now
    end
  end

  add pantographs_path, lastmod: Time.now
end
