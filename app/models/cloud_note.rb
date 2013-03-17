class CloudNote < ActiveRecord::Base

  include SyncHelper

  attr_accessible :cloud_note_identifier, :cloud_service_id, :note_id, :dirty, :attempts, :content_hash, :update_sequence_number

  belongs_to :note, :dependent => :destroy
  belongs_to :cloud_service

  scope :need_syncdown, where("dirty = ? AND attempts <= ?", true, Settings.notes.attempts).order('updated_at')
  scope :maxed_out, where("attempts > ?", Settings.notes.attempts).order('updated_at')

  # REVIEW: We don't validate for the presence of note since we want to be able to create dirty CloudNotes
  #  which may then be deleted. Creating a large number of superfluous notes would unnecessarily
  #  inflate the id number of each 'successful' note.
  validates :cloud_service, :presence => true
  validates :cloud_note_identifier, :presence => true, :uniqueness => { :scope => :cloud_service_id }

  validates_associated :note, :cloud_service
end
