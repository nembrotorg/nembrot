SitemapGenerator::Sitemap.default_host = "http://#{ Constant.host }"

SitemapGenerator::Sitemap.create do

  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  unless Book.cited.all.empty?
    add books_path

    Book.cited.each do |book|
      add book_path(book), lastmod: book.updated_at
    end
  end

  unless Link.publishable.all.empty?
    add links_path

    Link.publishable.each do |link|
      add link_path(link), lastmod: link.updated_at
    end
  end

  unless Note.publishable.listable.all.empty?
    add notes_path

    Note.publishable.listable.each do |note|
      add note_or_feature_path(note), lastmod: note.external_updated_at
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
