class Tag < ActiveRecord::Base
#class ActsAsTaggableOn::Tag < ActiveRecord::Base
  # WARNING: Could conflict with Tag model maintained by Act As Taggable On?

  #scope clean_tags, find_all { |tag| tag.name.match(/^[^_]/) }.sort_by { |tag| tag.name.downcase }

  default_scope :order => 'name'

  def to_param
    name.parameterize
  end
end
