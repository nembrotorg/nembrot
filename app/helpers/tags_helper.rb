module TagsHelper
  include ActsAsTaggableOn::TagsHelper

  def link_to_tag_unless_obsolete(tag)
    if tag.obsolete
      tag.name
    else
      link_to_unless_current tag.name, tag_path(tag.slug)
    end
  end
end
