class Resource < ActiveRecord::Base
  attr_accessible :note_id, :cloud_resource_identifier, :mime, :width, :height, :caption,
  :description, :credit, :source_url, :external_updated_at, :latitude, :longitude, :altitude,
  :camera_make, :camera_model, :file_name, :attachment, :data_hash, :dirty, :sync_retries

  belongs_to :note

  scope :needs_syncdown, where("dirty = ? AND sync_retries <= ?", true, Settings.notes.sync_retries).order('updated_at')
  scope :attached_images, where(:attachment => nil)
  scope :attached_files, where(:attachment => nil)

  validates :note, :presence => true
  validates :cloud_resource_identifier, :presence => true, :uniqueness => true

  validates_associated :note
end
