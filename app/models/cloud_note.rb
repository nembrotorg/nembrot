class CloudNote < ActiveRecord::Base
  attr_accessible :cloud_note_identifier

  belongs_to :note, :dependent => :destroy

  belongs_to :cloud_service

  validates :cloud_note_identifier, :note, :cloud_service, :presence => true
end
