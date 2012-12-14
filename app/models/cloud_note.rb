class CloudNote < ActiveRecord::Base
  attr_accessible :cloud_note_identifier, :cloud_service_id, :note_id, :dirty, :sync_retries, :content_hash

  belongs_to :note, :dependent => :destroy

  belongs_to :cloud_service

  scope :needs_syncdown, where("dirty = ? AND sync_retries <= ?", true, Settings.notes.sync_retries).order('updated_at')

  validates :cloud_note_identifier, :note, :cloud_service, :presence => true
  validates :cloud_note_identifier, :uniqueness => { :scope => :cloud_service_id }

  validates_associated :note, :cloud_service
end
