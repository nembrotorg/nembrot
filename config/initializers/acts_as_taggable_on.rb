ActsAsTaggableOn.remove_unused_tags = true

ActsAsTaggableOn::Tag.class_eval do

  attr_accessor :diff_status, :obsolete

  default_scope { order('slug') }

  def to_param
    slug
  end

	extend FriendlyId
		friendly_id :name, use: :slugged
end

# TEMPORARY: for Rails 4 compatibility, when we remove attribute accessor gem, we can remove this
#  https://github.com/mbleigh/acts-as-taggable-on/issues/389
module ActsAsTaggableOn
  class Tag
    attr_accessible :name
  end

  class Tagging
    attr_accessible :tag_id, :context, :taggable
  end
end
