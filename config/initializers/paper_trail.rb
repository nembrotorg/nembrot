class Version < ActiveRecord::Base
  attr_accessible :sequence, :tag_list, :instruction_list
  serialize :tag_list
  serialize :instruction_list
end
