# encoding: utf-8

class EvernoteNote < ActiveRecord::Base

  include EvernoteHelper
  include SyncHelper

  attr_accessible :cloud_note_identifier, :evernote_auth_id, :note_id, :dirty, :attempts, :content_hash, :update_sequence_number

  belongs_to :note, :dependent => :destroy
  belongs_to :evernote_auth

  scope :need_syncdown, where("dirty = ? AND attempts <= ?", true, Settings.notes.attempts).order('updated_at')
  scope :maxed_out, where("attempts > ?", Settings.notes.attempts).order('updated_at')

  # REVIEW: We don't validate for the presence of note since we want to be able to create dirty CloudNotes
  #  which may then be deleted. Creating a large number of superfluous notes would unnecessarily
  #  inflate the id number of each 'successful' note.
  validates :evernote_auth, :presence => true
  validates :cloud_note_identifier, :presence => true, :uniqueness => { :scope => :evernote_auth_id }

  validates_associated :note, :evernote_auth

  def self.add_task(guid)
    self.where(cloud_note_identifier: guid, evernote_auth_id: evernote_auth.id).first_or_create.dirtify
  end

  def self.sync_all
    need_syncdown.each { |evernote_note| evernote_note.syncdown_one }
  end

  def self.bulk_sync
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(
      notebookGuid: Settings.evernote.notebooks,
      words: Settings.evernote.instructions.required.join(' ').gsub(/^/, 'tag:').gsub(/ /, ' tag:'),
      order: 2,
      ascending: false
    )
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    evernote_notes = evernote_auth.note_store
                  .findNotesMetadata(evernote_auth.oauth_token, filter, 0, 999, spec)
    evernote_notes.notes.each do |evernote_note|
      EvernoteNote.add_task(evernote_note.guid)
    end
  end

  def syncdown_one
    # TODO: If source_url is an image, download it (and keep as source...)

    increment_attempts

    evernote_note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)

    # File.open('evernote_metadata.json', 'w') 
    # {|f| f.write(evernote_note_metadata.to_json) }

    error_details = error_details(evernote_note_metadata)

    if evernote_notebook_not_required?(evernote_note_metadata.notebookGuid)
      destroy
      logger.info I18n.t('notes.sync.rejected.not_in_notebook', error_details)

    elsif !evernote_note_metadata.active
      # note.update_attributes( :active => false )
      logger.info I18n.t('notes.sync.rejected.deleted_note', error_details)

    else
      evernote_note_tags = note_store.getNoteTagNames(oauth_token, guid)

      if evernote_note_not_required?(evernote_note_tags)

        if note.nil?
          delete
        else
          note.update_attributes(active: false)
          logger.info I18n.t('notes.sync.rejected.tag_missing', error_details)
          undirtify
        end

      elsif evernote_note_ignorable?(evernote_note_tags)
        logger.info I18n.t('notes.sync.rejected.ignore', error_details)
        undirtify

      elsif evernote_note_not_updated?(evernote_note_metadata.updateSequenceNum)
        logger.info  I18n.t('notes.sync.rejected.not_latest', error_details)
        undirtify

      else
        # If this is a new EvernoteNote, we only create a note here since
        # many CloudNotes will be created and then destroyed if they're not
        # required.
        build_note if note.nil?

        evernote_note_data = get_new_content_from_cloud(evernote_note_metadata)
        note.update_with_evernote_data(evernote_note_data, evernote_note_tags)
        update_with_data_from_cloud(evernote_note_data)
      end
    end

    rescue Evernote::EDAM::Error::EDAMUserException => error
      max_out_attempts
      sync_error('Evernote', guid, user_nickname,
                 "User Exception: #{ Settings.evernote.errors[error.errorCode] } (#{ error.parameter }).")

    rescue Evernote::EDAM::Error::EDAMNotFoundException => error
      max_out_attempts
      sync_error('Evernote', guid, user_nickname, "Not Found Exception: #{ error.identifier }: #{ error.key }.")

    rescue Evernote::EDAM::Error::EDAMSystemException => error
      sync_error('Evernote', guid, user_nickname, "User Exception: error #{ error.errorCode }: #{ error.message }.")
  end

  private

  def self.evernote_auth
    EvernoteAuth.first_or_create
  end

  def guid
    cloud_note_identifier
  end

  def evernote_notebook_not_required?(evernote_notebook_identifier)
    !Settings.evernote.notebooks.include?(evernote_notebook_identifier)
  end

  def evernote_note_not_required?(evernote_note_tags)
    ((Settings.evernote.instructions.required & evernote_note_tags) != Settings.evernote.instructions.required)
  end

  def evernote_note_ignorable?(evernote_note_tags)
    (!(Settings.evernote.instructions.ignore & evernote_note_tags).empty?)
  end

  def evernote_note_not_updated?(evernote_note_data_update_sequence_number)
    (note && update_sequence_number >= evernote_note_data_update_sequence_number)
  end

  def update_with_data_from_cloud(note_data)
    update_attributes!(
      note_id: note.id,
      attempts: 0,
      content_hash: note_data.contentHash,
      update_sequence_number: note_data.updateSequenceNum,
      dirty: false
    )
  end

  def get_new_content_from_cloud(note_data)
    note_data.content = note.body
    if note_data.contentHash != content_hash
      note_data = note_store.getNote(oauth_token, guid, true, false, false, false)
      note_data.content = Nokogiri::XML(note_data.content).css('en-note').inner_html
    end
    note_data
  end
end
