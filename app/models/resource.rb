class Resource < ActiveRecord::Base

  include ApplicationHelper

  attr_accessible :note_id, :cloud_resource_identifier, :mime, :width, :height, :caption,
  :description, :credit, :source_url, :external_updated_at, :latitude, :longitude, :altitude,
  :camera_make, :camera_model, :file_name, :local_file_name, :attachment, :data_hash, :dirty, :sync_retries

  belongs_to :note

  scope :needs_syncdown, where("dirty = ? AND sync_retries <= ?", true, Settings.notes.sync_retries).order('updated_at')
  scope :attached_images, where("mime LIKE 'image%'").where( :attachment => nil)
  scope :attached_files, where(:mime => 'application/pdf')

  validates :note, :presence => true
  validates :cloud_resource_identifier, :presence => true, :uniqueness => true

  validates_associated :note

  after_validation :make_local_file_name

  def file_ext
    (Mime::Type.file_extension_of self.mime).parameterize
  end

  def raw_location
      file_name = self.local_file_name
      File.join(Rails.root, 'public', 'resources', 'raw', "#{ file_name }.#{ self.file_ext }" )
  end

  def cut_location(aspect_x, aspect_y, width, snap, gravity, effects)
    file_name_out = File.join(Rails.root, 'public', 'resources', 'cut', "#{ self.local_file_name }-#{ aspect_x }-#{ aspect_y }-#{ width }-#{ snap }-#{ gravity }-#{ effects }.#{ self.file_ext }")
  end

  def template_location(aspect_x, aspect_y)
    file_name_template = File.join(Rails.root, 'public', 'resources', 'templates', "#{ self.cloud_resource_identifier }-#{ aspect_x }-#{ aspect_y }.#{ self.file_ext }")
  end

  def blank_location
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ self.file_ext }")
  end

  private
    def make_local_file_name
      if self.mime && self.mime !~ /image/
        local_file_name = File.basename(self.file_name, File.extname(self.file_name))
      elsif self.caption
        local_file_name = snippet(self.caption, Settings.styling.images.name_length, '')
      elsif self.description
        local_file_name = snippet(self.description, Settings.styling.images.name_length, '')
      elsif self.file_name
        local_file_name = File.basename(self.file_name, File.extname(self.file_name))
      else
        local_file_name = self.cloud_resource_identifier
      end
      self.local_file_name = local_file_name.parameterize
    end
end
