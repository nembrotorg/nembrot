class Version < ActiveRecord::Base
  attr_accessible :sequence, :tags, :instructions
  serialize :tags
  serialize :instructions
end
