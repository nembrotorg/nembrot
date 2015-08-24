# encoding: utf-8

class Resource < ActiveRecord::Base
  include Evernotable
  include Syncable

  belongs_to :note

  default_scope { order('id ASC') }
  # REVIEW: Evernote's attachment flag is inconsistent across source apps, use __INLINE
  # scope :attached_images, -> { where('mime LIKE ? AND dirty = ?', 'image%', false).where(attachment: nil).where('width > ?', NB.images_min_width.to_i) }
  scope :attached_images, -> { where('mime LIKE ? AND dirty = ?', 'image%', false).where('width > ?', NB.images_min_width.to_i) }
  scope :attached_files, -> { where('mime = ? AND dirty = ?', 'application/pdf', false) }

  validates_presence_of :cloud_resource_identifier, :note
  validates_uniqueness_of :cloud_resource_identifier, scope: :note_id

  validates_associated :note

  before_validation :make_local_file_name
  before_destroy :delete_binaries

  def self.sync_all_binaries
    need_syncdown.each(&:sync_binary)
  end

  def self.blank_location(file_ext = 'png')
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ file_ext }")
  end

  def blank_location
    # REVIEW: Reuse above
    File.join(Rails.root, 'public', 'resources', 'cut', "blank.#{ file_ext }")
  end

  def sync_binary
    unless File.file?(raw_location)
      NB.stream_binaries == 'true' ? stream_binary : download_binary
      # Check that the resource has been downloaded correctly. If so, unflag it.
      if Digest::MD5.file(raw_location).digest == data_hash
        undirtify
        attachments = { image_url: raw_url }
        Slack.ping("Image added: #{ caption }", icon_url: NB.logo_url, attachments: attachments)
      end
    end
  end

  def stream_binary
    require 'net/http'
    require 'uri'

    uri = URI.parse("#{ evernote_auth.url_prefix }/res/#{ cloud_resource_identifier }")
    connection = Net::HTTP.new(uri.host)
    connection.use_ssl = true if uri.scheme == 'https'

    connection.start do |_http|
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

  def raw_url
    'http://' + NB.host + '/' + File.join(Rails.root, 'resources', 'raw', "#{ mime == 'application/pdf' ? local_file_name : id }.#{ file_ext }")
  end

  def raw_location
    File.join(Rails.root, 'public', 'resources', 'raw', "#{ mime == 'application/pdf' ? local_file_name : id }.#{ file_ext }")
  end

  def template_location(aspect_x, aspect_y)
    File.join(Rails.root, 'public', 'resources', 'templates', "#{ id }-#{ aspect_x }-#{ aspect_y }.#{ file_ext }")
  end

  def cut_location(aspect_x, aspect_y, width, snap, gravity, effects = '')
    File.join(Rails.root, 'public', 'resources', 'cut', "#{ local_file_name }-#{ aspect_x }-#{ aspect_y }-#{ width }-#{ snap }-#{ gravity }-#{ effects }-#{ id }.#{ file_ext }")
  end

  def larger_cut_image_location(aspect_x, aspect_y, width, snap, gravity, effects, total_columns)
    # Try to find a larger image which has already been cut
    pattern = File.join(Rails.root, 'public', 'resources', 'cut', "#{ local_file_name }-#{ aspect_x }-#{ aspect_y }-*-#{ snap }-#{ gravity }-#{ effects }-#{ id }.#{ file_ext }")
    candidates = Dir.glob(pattern)
    candidates.select! do |c|
      file_width = c.match(/#{ local_file_name }-#{ aspect_x }-#{ aspect_y }-([0-9]*)-#{ snap }-#{ gravity }-#{ effects }-#{ id }.#{ file_ext }$/)[1].to_i
      # Allow for shorthand width
      # (This misses cases where cut width is, say, 200 and requested width is 12 - but not a 'real' use case)
      if width <= total_columns
        file_width >= width && file_width <= total_columns
      else
        file_width >= width 
      end
    end
    candidates.first
  end

  def gmaps4rails_title
    caption
  end

  # private

  def make_local_file_name
    if mime && mime !~ /image/
      new_name = File.basename(file_name, File.extname(file_name))
    elsif caption && !caption[/[a-zA-Z\-]{5,}/].blank? # Ensure caption is in Latin script and at least 5 characters
      new_name = caption[0..NB.images_name_length.to_i]
    elsif description && !description[/[a-zA-Z\-]{5,}/].blank?
      new_name = description[0..NB.images_name_length.to_i]
    elsif file_name && !file_name.empty?
      new_name = File.basename(file_name, File.extname(file_name))
    end
    new_name = cloud_resource_identifier if new_name.blank?
    self.local_file_name = new_name.parameterize
  end

  # REVIEW: Put this in EvernoteNote? and mimic Books?
  def update_with_evernote_data(cloud_resource, caption, description, credit)
    update_attributes!(
      altitude: cloud_resource.attributes.altitude,
      attachment: cloud_resource.attributes.attachment,
      camera_make: cloud_resource.attributes.cameraMake,
      camera_model: cloud_resource.attributes.cameraModel,
      caption: caption,
      credit: credit,
      data_hash: cloud_resource.data.bodyHash,
      description: description,
      dirty: true,
      external_updated_at: cloud_resource.attributes.timestamp ? Time.at(cloud_resource.attributes.timestamp / 1000).to_datetime : nil,
      file_name: cloud_resource.attributes.fileName,
      height: cloud_resource.height,
      latitude: cloud_resource.attributes.latitude,
      local_file_name: cloud_resource.guid,
      longitude: cloud_resource.attributes.longitude,
      mime: cloud_resource.mime,
      source_url: cloud_resource.attributes.sourceURL,
      width: cloud_resource.width
    )
    SyncResourceJob.perform_later(self) if cloud_resource.data.bodyHash != data_hash
  end

  def delete_binaries
    File.delete raw_location if File.exist? raw_location
    Dir.glob("public/resources/templates/#{ id }*.*").each do |binary|
      File.delete binary if File.exist? binary
    end
    Dir.glob("public/resources/cut/*-#{ id }.*").each do |binary|
      File.delete binary if File.exist? binary
    end
  end
end
