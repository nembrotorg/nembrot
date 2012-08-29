class CloudService < ActiveRecord::Base
  attr_accessible :name

  has_many :cloud_notes, :dependent => :destroy

  validates :name, :presence => true, :uniqueness => true
end
