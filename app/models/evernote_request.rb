# encoding: utf-8

class EvernoteRequest

  include Evernotable
  include Syncable

  attr_accessor :data, :evernote_note, :evernote_auth, :note, :guid, :cloud_note_metadata, :cloud_note_data, 
                :cloud_note_tags, :offline

  def sync_down(evernote_note)
    evernote_note.build_note if evernote_note.note.nil?

    self.evernote_note = evernote_note
    self.guid = evernote_note.cloud_note_identifier
    self.evernote_auth = evernote_note.evernote_auth

    evernote_note.increment_attempts

    self.cloud_note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)

    update_note if update_necessary? && note_is_not_conflicted?

    rescue Evernote::EDAM::Error::EDAMUserException => error
      max_out_attempts
      SYNC_LOG.error I18n.t('notes.sync.rejected.not_in_notebook', logger_details)
    rescue Evernote::EDAM::Error::EDAMNotFoundException => error
      max_out_attempts
      SYNC_LOG.error "Evernote: Not Found Exception: #{ error.identifier }: #{ error.key }."
    rescue Evernote::EDAM::Error::EDAMSystemException => error
      SYNC_LOG.error "Evernote: User Exception: #{ error.identifier }: #{ error.key }."
  end

  def update_necessary?
    update_necessary_according_to_note? && update_necessary_according_to_tags?
  end

  private

  def update_note
    populate
    evernote_note.note.merge(data, true)
    evernote_note.note.save!
    update_resources_with_evernote_data(cloud_note_data)
    update_evernote_note_with_evernote_data(cloud_note_data)
    SYNC_LOG.info "#{ logger_details[:title] } saved as #{ evernote_note.note.type } #{ evernote_note.note.id }."
  end

  def update_necessary_according_to_note?
    necessary = (evernote_notebook_required? && cloud_note_active? && cloud_note_updated?)
    self.cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid) if necessary.blank? && cloud_note_tags.blank?
    necessary
  end

  def evernote_notebook_required?
    required = Array(Settings.channel.evernote_notebooks).include?(cloud_note_metadata.notebookGuid)
    unless required
      evernote_note.destroy!
      SYNC_LOG.info I18n.t('notes.sync.rejected.not_in_notebook', logger_details)
    end
    required
  end

  def cloud_note_active?
    active = cloud_note_metadata.active
    unless active
      evernote_note.destroy!
      SYNC_LOG.info I18n.t('notes.sync.rejected.deleted_note', logger_details)
    end
    active
  end

  def cloud_note_updated?
    updated = evernote_note.update_sequence_number.blank? || (evernote_note.update_sequence_number < cloud_note_metadata.updateSequenceNum)
    unless updated
      evernote_note.undirtify
      SYNC_LOG.info I18n.t('notes.sync.rejected.not_latest', logger_details)
    end
    updated
  end

  def update_necessary_according_to_tags?
    self.cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid) if cloud_note_tags.blank?
    cloud_note_has_required_tags? && cloud_note_is_not_ignorable?
  end

  def cloud_note_has_required_tags?
    has_required_tags = !(Array(Settings.channel.instructions_required) & cloud_note_tags).empty?
    unless has_required_tags
      evernote_note.destroy!
      SYNC_LOG.info I18n.t('notes.sync.rejected.tag_missing', logger_details)
    end
    has_required_tags
  end

  def cloud_note_is_not_ignorable?
    not_ignorable = (Settings.channel.instructions_ignore & cloud_note_tags).empty?
    unless not_ignorable
      SYNC_LOG.info I18n.t('notes.sync.rejected.ignore', logger_details)
      evernote_note.undirtify
    end
    not_ignorable
  end

  def note_is_not_conflicted?
    get_new_content_from_cloud_if_updated
    not_conflicted = cloud_note_data.content.scan(I18n.t('notes.sync.conflicted.warning_string')).empty?
    unless not_conflicted
      CloudNoteMailer.syncdown_note_failed('Evernote', cloud_note_metadata.guid, cloud_note_metadata.title, user_nickname, 'conflicted').deliver
      SYNC_LOG.error I18n.t('notes.sync.conflicted.logger', logger_details)
    end
    not_conflicted
  end

  def get_new_content_from_cloud_if_updated
    cloud_note_data = cloud_note_metadata
    cloud_note_data.content = evernote_note.note.body
    if cloud_note_data.contentHash != evernote_note.content_hash
      note_data = note_store.getNote(oauth_token, guid, true, false, false, false) unless offline
      cloud_note_data.content = Nokogiri.XML(note_data.content).css('en-note').inner_html
    end
    self.cloud_note_data = cloud_note_data
  end

  def calculate_updated_at
    reset_new_note = Settings.channel.always_reset_on_create && evernote_note.note.new_record?
    use_date = reset_new_note ?  cloud_note_data.created : cloud_note_data.updated
    Time.at(use_date / 1000).to_datetime
  end

  def populate
    self.data = {
      'title'               => cloud_note_data.title,
      'body'                => cloud_note_data.content,
      'latitude'            => cloud_note_data.attributes.latitude,
      'longitude'           => cloud_note_data.attributes.longitude,
      'altitude'            => cloud_note_data.attributes.altitude,
      'place'               => cloud_note_data.attributes.placeName,
      'external_updated_at' => calculate_updated_at,
      'author'              => cloud_note_data.attributes.author,
      'content_class'       => cloud_note_data.attributes.contentClass,
      'last_edited_by'      => cloud_note_data.attributes.lastEditedBy,
      'source'              => cloud_note_data.attributes.source,
      'source_application'  => cloud_note_data.attributes.sourceApplication,
      'source_url'          => cloud_note_data.attributes.sourceURL,
      'tag_list'            => cloud_note_tags.grep(/^[^_]/),
      'instruction_list'    => cloud_note_tags.grep(/^_/),
      'active'              => true
    }
  end

  def update_evernote_note_with_evernote_data(cloud_note_data)
    evernote_note.update_attributes!(
      note_id: evernote_note.note.id,
      attempts: 0,
      content_hash: cloud_note_data.contentHash,
      update_sequence_number: cloud_note_data.updateSequenceNum,
      dirty: false
    )
  end

  # REVIEW: When a note contains both images and downloads, the alt/cap is disrupted
  def update_resources_with_evernote_data(cloud_note_data)
    cloud_resources = cloud_note_data.resources

    # Since we're reading straight from Evernote data we use <div> and </div> rather than ^ and $ as line delimiters.
    #  If we end up using a sanitized version of the body for other uses (e.g. wordcount), then we can use that.
    captions = cloud_note_data.content.scan(/<div>\s*cap:\s*(.*?)\s*<\/div>/i)
    descriptions = cloud_note_data.content.scan(/<div>\s*(?:alt|description):\s*(.*?)\s*<\/div>/i)
    credits = cloud_note_data.content.scan(/<div>\s*credit:\s*(.*?)\s*<\/div>/i)

    # First we remove all resources (to make sure deleted resources disappear -
    #  but we don't want to delete binaries so we use #delete rather than #destroy)
    evernote_note.note.resources.delete_all

    if cloud_resources
      cloud_resources.each_with_index do |cloud_resource, index|

        resource = evernote_note.note.resources.where(cloud_resource_identifier: cloud_resource.guid).first_or_create

        caption = captions[index] ? captions[index][0] : ''
        description = descriptions[index] ? descriptions[index][0] : ''
        credit = credits[index] ? credits[index][0] : ''

        # REVIEW: see comment in Resource
        resource.update_with_evernote_data(cloud_resource, caption, description, credit)
      end
    end
  end

end
