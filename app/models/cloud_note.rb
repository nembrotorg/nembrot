class CloudNote < ActiveRecord::Base
  attr_accessible :cloud_note_identifier, :cloud_service_id

  belongs_to :note, :dependent => :destroy

  belongs_to :cloud_service

  validates :cloud_note_identifier, :note, :cloud_service, :presence => true
  validates :cloud_note_identifier, :uniqueness => { :scope => :cloud_service_id }

  validates_associated :note, :cloud_service

  # It should validate to ensure that new version is more recent than current one

end
