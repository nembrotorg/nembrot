class Resource < ActiveRecord::Base

  include EvernoteHelper
  include SyncHelper

  attr_accessible :note_id, :cloud_resource_identifier, :mime, :width, :height, :caption,
  :description, :credit, :source_url, :external_updated_at, :latitude, :longitude, :altitude,
  :camera_make, :camera_model, :file_name, :local_file_name, :attachment, :data_hash, :dirty, :attempts

  belongs_to :note

  scope :need_syncdown, where("dirty = ? AND attempts <= ?", true, Settings.notes.attempts).order('updated_at')
  scope :maxed_out, where("attempts > ?", Settings.notes.attempts).order('updated_at')
  scope :attached_images, where("mime LIKE 'image%'").where( :attachment => nil)
  scope :attached_files, where(:mime => 'application/pdf')

  validates :note, :presence => true
  validates :cloud_resource_identifier, :presence => true, :uniqueness => true

  validates_associated :note

  #after_validation :make_local_file_name

  def file_ext
    (Mime::Type.file_extension_of mime).parameterize
  end

  def raw_location
      File.join(Rails.root, 'public', 'resources', 'raw', "#{ cloud_resource_identifier }.#{ file_ext }" )
  end

  def cut_location(aspect_x, aspect_y, width, snap, gravity, effects = "0")
    File.join(Rails.root, 'public', 'resources', 'cut', "#{ local_file_name }-#{ aspect_x }-#{ aspect_y }-#{ width }-#{ snap }-#{ gravity }-#{ effects }-#{ id }.#{ file_ext }")
  end

  def template_location(aspect_x, aspect_y)
    File.join(Rails.root, 'public', 'resources', 'templates', "#{ cloud_resource_identifier }-#{ aspect_x }-#{ aspect_y }.#{ file_ext }")
  end

  def blank_location
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ file_ext }")
  end

  #private

  def make_local_file_name
    if mime && mime !~ /image/
      local_file_name = File.basename(file_name, File.extname(file_name))
    elsif caption
      local_file_name = snippet(caption, Settings.styling.images.name_length, '')
    elsif description
      local_file_name = snippet(description, Settings.styling.images.name_length, '')
    elsif file_name && file_name != ''
      local_file_name = File.basename(file_name, File.extname(file_name))
    end

    if local_file_name.nil? || !local_file_name || local_file_name.empty?
      local_file_name = cloud_resource_identifier
    end

    local_file_name.parameterize
  end

  def update_with_evernote_data(cloud_resource, caption, description, credit)
    update_attributes!(
      :mime => cloud_resource.mime,
      :width => cloud_resource.width,
      :height => cloud_resource.height,
      :caption => caption,
      :description => description,
      :credit => credit,
      :source_url => cloud_resource.attributes.sourceURL,
      :external_updated_at => cloud_resource.attributes.timestamp ? Time.at(cloud_resource.attributes.timestamp / 1000).to_datetime : nil,
      :latitude => cloud_resource.attributes.latitude,
      :longitude => cloud_resource.attributes.longitude,
      :altitude => cloud_resource.attributes.altitude,
      :camera_make => cloud_resource.attributes.cameraMake,
      :camera_model => cloud_resource.attributes.cameraModel,
      :file_name => cloud_resource.attributes.fileName,
      :attachment => cloud_resource.attributes.attachment,
      :local_file_name => cloud_resource.guid,
      :data_hash => cloud_resource.data.bodyHash,
      :dirty => (cloud_resource.data.bodyHash != data_hash),
      :attempts => 0
    )
    update_attributes(
      :local_file_name => make_local_file_name
    )
  end

  def self.sync_all_binaries
    puts "Syncing all binaries..."
    need_syncdown.each do |resource|
      resource.sync_binary
    end
  end

  def sync_binary
    if !File.file?(raw_location)
      puts "Syncing binary #{ cloud_resource_identifier }..."

      increment_attempts

      if Settings.evernote.stream_binaries
        
        # Stream binary. NOT WORKING YET

        require "net/http"
        require "uri"

        uri = URI.parse("#{ cloud_service.evernote_url_prefix }/res/#{ cloud_resource_identifier }")

        http = Net::HTTP.new(uri.host)
        http.use_ssl = true if uri.scheme == 'https'
        http.start do |http|
          response = http.post_form(uri.path, { 'auth' => oauth_token })
          File.open(raw_location, 'wb') do |file|
            file.write(response.body)
          end
        end
      else

        # Download binary
        
        # To get the binary data via the API use this method (however, this way the whole file is downloaded into memory - 
        # see http://dev.evernote.com/start/core/resources.php#downloading )
        cloud_resource_data = note_store.getResourceData(oauth_token, cloud_resource_identifier)
        File.open(raw_location, 'wb') do |file|
          file.write(cloud_resource_data)
        end
      end

      # Also how do we delete images when a resource is deleted?
      # (A method in resource - checks file is not used by other resources first...?)

      # We check that the resource has been downloaded correctly, if so we unflag the resource.
      if Digest::MD5.file(raw_location).digest == data_hash
        undirtify
      end
    end
  end

  def cloud_service
    CloudNote.find_by_note_id(note.id).cloud_service
  end
end
