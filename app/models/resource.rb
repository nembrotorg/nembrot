# encoding: utf-8

class Resource < ActiveRecord::Base

  include Evernotable
  include Syncable

  belongs_to :note

  scope :attached_images, -> { where("mime LIKE 'image%' AND dirty = ?", false).where(attachment: nil) }
  scope :attached_files, -> { where(mime: 'application/pdf AND dirty = ?', false) }
  scope :need_syncdown, -> { where('dirty = ? AND attempts <= ?', true, Settings.notes.attempts).order('updated_at') }
  scope :maxed_out, -> { where('attempts > ?', Settings.notes.attempts).order('updated_at') }

  validates :note, presence: true
  validates :cloud_resource_identifier, presence: true, uniqueness: true

  validates_associated :note

  before_validation :make_local_file_name
  before_destroy :delete_binaries

  def self.sync_all_binaries
    need_syncdown.each { |resource| resource.sync_binary }
  end

  def sync_binary
    unless File.file?(raw_location)
      increment_attempts
      Settings.evernote.stream_binaries ? stream_binary : download_binary
      # We check that the resource has been downloaded correctly, if so we unflag the resource.
      undirtify if Digest::MD5.file(raw_location).digest == data_hash
    end
  end

  def stream_binary
    require 'net/http'
    require 'uri'

    uri = URI.parse("#{ evernote_auth.url_prefix }/res/#{ cloud_resource_identifier }")
    connection = Net::HTTP.new(uri.host)
    connection.use_ssl = true if uri.scheme == 'https'

    connection.start do |http|
      response = connection.post_form(uri.path, { 'auth' => oauth_token })
      File.open(raw_location, 'wb') do |file|
        file.write(response.body)
      end
    end
  end

  def download_binary
    # This way the whole file is downloaded into memory -
    #  see http://dev.evernote.com/start/core/resources.php#downloading
    cloud_resource_data = note_store.getResourceData(oauth_token, cloud_resource_identifier)
    File.open(raw_location, 'wb') do |file|
      file.write(cloud_resource_data)
    end
  end

  def evernote_auth
    EvernoteNote.find_by_note_id(note.id).evernote_auth
  end

  def file_ext
    (Mime::Type.file_extension_of mime).parameterize
  end

  def raw_location
    File.join(Rails.root, 'public', 'resources', 'raw', "#{ mime == 'application/pdf' ? local_file_name : id }.#{ file_ext }")
  end

  def template_location(aspect_x, aspect_y)
    File.join(Rails.root, 'public', 'resources', 'templates', "#{ id }-#{ aspect_x }-#{ aspect_y }.#{ file_ext }")
  end

  def cut_location(aspect_x, aspect_y, width, snap, gravity, effects = '0')
    File.join(Rails.root, 'public', 'resources', 'cut', "#{ local_file_name }-#{ aspect_x }-#{ aspect_y }-#{ width }-#{ snap }-#{ gravity }-#{ effects }-#{ id }.#{ file_ext }")
  end

  def blank_location
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ file_ext }")
  end

  # private

  def make_local_file_name
    if mime && mime !~ /image/
      new_name = File.basename(file_name, File.extname(file_name))
    elsif caption && !caption[/[a-zA-Z\-]{5,}/].blank? # Ensure caption is in Latin script and at least 5 characters
      new_name = caption[0..Settings.styling.images.name_length]
    elsif description && !description[/[a-zA-Z\-]{5,}/].blank?
      new_name = description[0..Settings.styling.images.name_length]
    elsif file_name && !file_name.empty?
      new_name = File.basename(file_name, File.extname(file_name))
    end
    new_name = cloud_resource_identifier if new_name.blank?
    self.local_file_name = new_name.parameterize
  end

  # REVIEW: Put this in EvernoteNote? and mimic Books?
  def update_with_evernote_data(cloud_resource, caption, description, credit)
    update_attributes!(
      mime: cloud_resource.mime,
      width: cloud_resource.width,
      height: cloud_resource.height,
      caption: caption,
      description: description,
      credit: credit,
      source_url: cloud_resource.attributes.sourceURL,
      external_updated_at: cloud_resource.attributes.timestamp ? Time.at(cloud_resource.attributes.timestamp / 1000).to_datetime : nil,
      latitude: cloud_resource.attributes.latitude,
      longitude: cloud_resource.attributes.longitude,
      altitude: cloud_resource.attributes.altitude,
      camera_make: cloud_resource.attributes.cameraMake,
      camera_model: cloud_resource.attributes.cameraModel,
      file_name: cloud_resource.attributes.fileName,
      attachment: cloud_resource.attributes.attachment,
      local_file_name: cloud_resource.guid,
      data_hash: cloud_resource.data.bodyHash,
      dirty: (cloud_resource.data.bodyHash != data_hash),
      attempts: 0
    )
  end

  def delete_binaries
    File.delete raw_location if File.exists? raw_location
    Dir.glob("public/resources/templates/#{ id }*.*").each do |binary|
      File.delete binary if File.exists? binary
    end
    Dir.glob("public/resources/cut/*-#{ id }.*").each do |binary|
      File.delete binary if File.exists? binary
    end
  end
end
