class Version < ActiveRecord::Base
  attr_accessible :sequence, :tags
  serialize :tags
end