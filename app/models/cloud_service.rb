class CloudService < ActiveRecord::Base
  attr_accessible :name

  has_many :cloud_notes, :dependent => :destroy

  attr_encrypted :auth, :key => Secret.database_encryption_key, :marshal => true

  validates :name, :presence => true, :uniqueness => true
end
