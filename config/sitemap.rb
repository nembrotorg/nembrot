SitemapGenerator::Sitemap.default_host = "http://#{ Constant.host }"

SitemapGenerator::Sitemap.create do


  Channel.where.not(slug: 'default').each do |channel|

    add home_path(channel)

    unless Note.channelled(channel).publishable.listable.empty?
      add notes_path(channel)

      Note.channelled(channel).publishable.listable.each do |note|
        # REVIEW: Unable to include ApplicationHelper here
        # Feaure and section indices are added later
        if note.feature.nil? || !note.feature_id.nil?
          add (note.has_instruction?('feature') ? feature_path(channel: channel.slug, feature: note.feature, feature_id: note.feature_id) : note_path(channel: channel.slug, id: note.id)),
           lastmod: note.external_updated_at,
           priority: (note.is_feature? && !note.is_section?) ? 0.8 : 0.7
        end
      end

      Note.channelled(channel).features.each do |feature|
        add feature_path(channel: channel.slug, feature: feature), priority: 0.9
      end

      # REVIEW: Lastmod here becomes more recent than anything else
      Note.channelled(channel).sections.each do |section|
        add feature_path(channel: channel.slug, feature: section)
      end
    end

    unless Note.channelled(channel).publishable.tag_counts_on(:tags).empty?
      add tags_path(channel)

      Note.channelled(channel).publishable.tag_counts_on(:tags).each do |tag|
        add tag_path(channel: channel.slug, slug: tag.slug), lastmod: Time.now
      end
    end
  end
end
