ActsAsTaggableOn.remove_unused_tags = true

ActsAsTaggableOn::Tag.class_eval do
  default_scope :order => 'name'
	extend FriendlyId
		friendly_id :name, use: :slugged
end
