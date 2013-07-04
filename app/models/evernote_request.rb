# encoding: utf-8

class EvernoteRequest

  include EvernoteHelper
  include SyncHelper

  attr_accessor :data, :evernote_note, :evernote_auth, :note, :guid, :cloud_note_metadata, :cloud_note_data, 
                :cloud_note_tags, :offline

  def initialize(evernote_note, offline = false)
    evernote_note.build_note if evernote_note.note.nil?

    self.evernote_note = evernote_note
    self.offline = offline
    self.guid = evernote_note.cloud_note_identifier
    self.evernote_auth = evernote_note.evernote_auth

    evernote_note.increment_attempts

    self.cloud_note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false) unless offline

    update_note if update_necessary?

    rescue Evernote::EDAM::Error => error
      max_out_attempts
      SYNC_LOG.info I18n.t('notes.sync.updated', logger_details)
  end

  private

  def update_necessary?
    update_necessary_according_to_note? && update_necessary_according_to_tags?
  end

  def update_note
    get_new_content_from_cloud_if_updated
    populate
    evernote_note.note.merge(data, true)
    evernote_note.note.save!
    evernote_note.note.update_resources_with_evernote_data(cloud_note_data)
    evernote_note.update_with_data_from_cloud(cloud_note_data)
    SYNC_LOG.info "#{ logger_details[:title] } saved as Note #{ (evernote_note.note.id) }."
  end

  def update_necessary_according_to_note?
    result = (evernote_notebook_required? && cloud_note_active? && cloud_note_updated?)
    self.cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid) unless result
    result
  end

  def evernote_notebook_required?
    result = Settings.evernote.notebooks.include?(cloud_note_metadata.notebookGuid)
    unless result
      evernote_note.destroy
      SYNC_LOG.info I18n.t('notes.sync.rejected.not_in_notebook', logger_details)
    end
    result
  end

  def cloud_note_active?
    result = cloud_note_metadata.active
    unless result
      evernote_note.destroy
      SYNC_LOG.info I18n.t('notes.sync.rejected.deleted_note', logger_details)
    end
    result
  end

  def cloud_note_updated?
    result = evernote_note.update_sequence_number.nil? || (evernote_note.update_sequence_number < cloud_note_metadata.updateSequenceNum)
    unless result
      evernote_note.undirtify
      SYNC_LOG.info I18n.t('notes.sync.rejected.not_latest', logger_details)
    end
    result
  end

  def update_necessary_according_to_tags?
    self.cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid) unless offline
    cloud_note_has_required_tags? && cloud_note_is_not_ignorable?
  end

  def cloud_note_has_required_tags?
    result = !(Array(Settings.notes.instructions.required) & cloud_note_tags).empty?
    unless result
      evernote_note.destroy
      SYNC_LOG.info I18n.t('notes.sync.rejected.tag_missing', logger_details)
    end
    result
  end

  def cloud_note_is_not_ignorable?
    result = (Settings.notes.instructions.ignore & cloud_note_tags).empty?
    unless result
      SYNC_LOG.info I18n.t('notes.sync.rejected.ignore', logger_details)
      evernote_note.undirtify
    end
    result
  end

  def get_new_content_from_cloud_if_updated
    cloud_note_data = cloud_note_metadata
    cloud_note_data.content = evernote_note.note.body
    if cloud_note_data.contentHash != evernote_note.content_hash
      note_data = note_store.getNote(oauth_token, guid, true, false, false, false) unless offline
      cloud_note_data.content = Nokogiri::XML(note_data.content).css('en-note').inner_html
    end
    self.cloud_note_data = cloud_note_data
  end

  def calculate_updated_at
    reset_new_note = Settings.evernote.always_reset_on_create && evernote_note.note.new_record? 
    use_date = reset_new_note ?  cloud_note_data.created : cloud_note_data.updated
    Time.at(use_date / 1000).to_datetime
  end

  def populate
    data = {}

    tag_list_from_note_data = cloud_note_tags.grep(/^[^_]/)
    cloud_note_instructions = cloud_note_tags.grep(/^_/)

    data['title']               = cloud_note_data.title
    data['body']                = cloud_note_data.content
    data['latitude']            = cloud_note_data.attributes.latitude
    data['longitude']           = cloud_note_data.attributes.longitude
    data['external_updated_at'] = calculate_updated_at
    data['author']              = cloud_note_data.attributes.author
    data['last_edited_by']      = cloud_note_data.attributes.lastEditedBy
    data['source']              = cloud_note_data.attributes.source
    data['source_application']  = cloud_note_data.attributes.sourceApplication
    data['source_url']          = cloud_note_data.attributes.sourceURL
    data['tag_list']            = tag_list_from_note_data
    data['instruction_list']    = cloud_note_instructions
    data['active']              = true

    self.data = data unless data.empty?
  end
end
