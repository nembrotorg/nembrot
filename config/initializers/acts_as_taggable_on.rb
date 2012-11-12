ActsAsTaggableOn.remove_unused_tags = true

ActsAsTaggableOn::Tag.class_eval do
	extend FriendlyId
		friendly_id :name, use: :slugged
end

class ActsAsTaggableOn::Tag < ActiveRecord::Base
  default_scope :order => 'name'
end
