class Resource < ActiveRecord::Base

  include ApplicationHelper
  include EvernoteHelper

  attr_accessible :note_id, :cloud_resource_identifier, :mime, :width, :height, :caption,
  :description, :credit, :source_url, :external_updated_at, :latitude, :longitude, :altitude,
  :camera_make, :camera_model, :file_name, :local_file_name, :attachment, :data_hash, :dirty, :sync_retries

  belongs_to :note

  # USE NOMENCLATURE FROM DELAYED_JOB
  scope :needs_syncdown, where("dirty = ? AND sync_retries <= ?", true, Settings.notes.sync_retries).order('updated_at')
  scope :maxed_out, where("sync_retries > ?", Settings.notes.sync_retries).order('updated_at')
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
      File.join(Rails.root, 'public', 'resources', 'raw', "#{ self.cloud_resource_identifier }.#{ self.file_ext }" )
  end

  def cut_location(aspect_x, aspect_y, width, snap, gravity, effects)
    File.join(Rails.root, 'public', 'resources', 'cut', "#{ self.local_file_name }-#{ aspect_x }-#{ aspect_y }-#{ width }-#{ snap }-#{ gravity }-#{ effects }.#{ self.file_ext }")
  end

  def template_location(aspect_x, aspect_y)
    File.join(Rails.root, 'public', 'resources', 'templates', "#{ self.cloud_resource_identifier }-#{ aspect_x }-#{ aspect_y }.#{ self.file_ext }")
  end

  def blank_location
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ self.file_ext }")
  end

  def dirtify
    self.update_attributes!(:dirty => true , :sync_retries => 0)
  end

  def undirtify
    self.update_attributes!(:dirty => false , :sync_retries => 0)
  end

  def increment_sync_retries
    self.increment!(:sync_retries)
  end

  def max_out_sync_retries
    self.update_attributes!( :sync_retries => Settings.notes.sync_retries + 1 )
  end

  def self.update_all_with_evernote(note, note_data)
    # When a note contains both images and downloads, the alt/cap is disrupted

    cloud_resources = note_data.resources
    captions = note_data.content.scan(/^\s*cap:\s*(.*?)\s*$/i)
    descriptions = note_data.content.scan(/^\s*[alt|description]:\s*(.*?)\s*$/i)

    if cloud_resources
      cloud_resources.each_with_index do |cloud_resource, index|

        # Better way of creating this one? note.resource(where).first_or_create ...?
        resource = Resource.where(:cloud_resource_identifier => cloud_resource.guid).first_or_create

        caption = captions[index] ? captions[index][0] : ''
        description = descriptions[index] ? descriptions[index][0] : ''

        resource.update_with_evernote(note, cloud_resource, caption, description)
      end
    end
  end

  def update_with_evernote(note, cloud_resource, caption, description)
    self.update_attributes!(
      :note_id => note.id,
      :mime => cloud_resource.mime,
      :width => cloud_resource.width,
      :height => cloud_resource.height,
      :caption => caption,
      :description => description,

      #Add captions to videos?
      #Add fx (similarly)
      #Remove credit - should just go with caption?
      #:credit => '',
      :source_url => cloud_resource.attributes.sourceURL,
      :external_updated_at => cloud_resource.attributes.timestamp ? Time.at(cloud_resource.attributes.timestamp / 1000).to_datetime : nil,
      :latitude => cloud_resource.attributes.latitude,
      :longitude => cloud_resource.attributes.longitude,
      :altitude => cloud_resource.attributes.altitude,
      :camera_make => cloud_resource.attributes.cameraMake,
      :camera_model => cloud_resource.attributes.cameraModel,
      :file_name => cloud_resource.attributes.fileName,
      :attachment => cloud_resource.attributes.attachment,
      :data_hash => cloud_resource.data.bodyHash,
      :dirty => (cloud_resource.data.bodyHash != self.data_hash),
      :sync_retries => 0
    )
  end

  def self.sync_all_binaries
    puts "Syncing all binaries..."

    # This should be genericised - use CURL, put curl url in record
      dirty_resources = self.needs_syncdown
      dirty_resources.each do |resource|
        resource.sync_binary
      end
  end

  def sync_binary
    if !File.file?(self.raw_location)
      puts "Syncing binary #{ self.cloud_resource_identifier }..."

      self.increment_sync_retries

      cloud_service = CloudNote.find_by_note_id(self.note.id).cloud_service
      note_store = cloud_service.evernote_note_store
      oauth_token = cloud_service.evernote_oauth_token

      if Settings.evernote.stream_binaries
        
        #Stream binary.

        require 'net/http'
        url_prefix = cloud_service.evernote_url_prefix

        require "net/http"
        require "uri"

        uri = URI.parse("#{ url_prefix }/res/#{ self.cloud_resource_identifier }")

        http = Net::HTTP.new(uri.host)
        http.use_ssl = true if uri.scheme == 'https'

        http.start do |http|
          response = http.post_form(uri.path, { 'auth' => oauth_token })
          File.open(self.raw_location, 'wb') do |file|
            file.write(response.body)
          end
        end
      else

        # Download binary
        
        # To get the binary data via the API use this method (however, this way the whole file is downloaded into memory - 
        # see http://dev.evernote.com/start/core/resources.php#downloading )
        cloud_resource_data = note_store.getResourceData(oauth_token, self.cloud_resource_identifier)
        File.open(self.raw_location, 'wb') do |file|
          file.write(cloud_resource_data)
        end

      end

      # Also how do we delete images when a resource is deleted?
      # (A method in resource - checks file is not used by other resources first...?)

      # We check that the resource has been downloaded correctly, if so we unflag the resource.
      if Digest::MD5.file(self.raw_location).digest == self.data_hash
        self.undirtify
      end
    end
  end

  private
    def make_local_file_name
      if self.mime && self.mime !~ /image/
        local_file_name = File.basename(self.file_name, File.extname(self.file_name))
      elsif self.caption
        local_file_name = snippet(self.caption, Settings.styling.images.name_length, '')
      elsif self.description
        local_file_name = snippet(self.description, Settings.styling.images.name_length, '')
      elsif self.file_name && self.file_name != ''
        local_file_name = File.basename(self.file_name, File.extname(self.file_name))
      end

      if local_file_name.nil? || !local_file_name || local_file_name.empty?
        local_file_name = self.cloud_resource_identifier
      end

      self.local_file_name = local_file_name.parameterize
    end
end
