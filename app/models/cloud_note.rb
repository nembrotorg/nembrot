class CloudNote < ActiveRecord::Base

  include EvernoteHelper

  attr_accessible :cloud_note_identifier, :cloud_service_id, :note_id, :dirty, :sync_retries, :content_hash

  belongs_to :note, :dependent => :destroy

  belongs_to :cloud_service

  scope :needs_syncdown, where("dirty = ? AND sync_retries <= ?", true, Settings.notes.sync_retries).order('updated_at')
  scope :maxed_out, where("sync_retries > ?", Settings.notes.sync_retries).order('updated_at')

  # validates :note, 
  validates :cloud_service, :presence => true
  validates :cloud_note_identifier, :presence => true, :uniqueness => { :scope => :cloud_service_id }

  validates_associated :note, :cloud_service

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
    self.update_attributes!(:sync_retries => Settings.notes.sync_retries + 1)
  end

  def self.sync_all_from_evernote
    puts "Syncing all evernote notes..."
    self.needs_syncdown.each do |cloud_note|
      cloud_note.sync_one_from_evernote
    end
  end

  # private
    def sync_one_from_evernote
      puts "Syncing #{ self.cloud_note_identifier }..."
      self.increment_sync_retries

      guid = self.cloud_note_identifier
      oauth_token = self.cloud_service.evernote_oauth_token
      note_store = self.cloud_service.evernote_note_store
      cloud_note_metadata = note_store.getNote(oauth_token, guid, false, false, false, false)
      nickname = self.cloud_service.evernote_nickname

      error_details = { :provider => 'Evernote', :guid => guid, :title => cloud_note_metadata.title, :username => self.cloud_service.auth.info.nickname }
      
      if self.evernote_notebook_required?(cloud_note_metadata)
        self.destroy
        logger.info t('notes.sync.rejected.not_in_notebook', error_details)
      elsif self.evernote_note_inactive?(cloud_note_metadata)
        self.update_attributes( :active => false )
        logger.info t('notes.sync.rejected.deleted_note', error_details)
      else
        cloud_note_tags = note_store.getNoteTagNames(oauth_token, guid)

        if self.evernote_note_required?(cloud_note_tags)
          self.update_attributes( :active => false )
          logger.info I18n.t('notes.sync.rejected.tag_missing', error_details)
        elsif self.evernote_note_ignore?(cloud_note_tags)
          logger.info I18n.t('notes.sync.rejected.ignore', error_details)
          self.max_out_sync_retries
        elsif self.evernote_note_updated?(cloud_note_metadata)
          logger.info  I18n.t('notes.sync.rejected.not_latest', error_details)
          self.max_out_sync_retries
        else

          cloud_note_data = self.evernote_update_note_data(cloud_note_metadata, note_store, oauth_token, guid)

          # We only create a note here since many CloudNotes will be created and then destroyed if they're not required.
          
          self.note = Note.new if self.note.nil?

          self.note.update_with_evernote(cloud_note_data, cloud_note_tags)
          Resource.update_all_with_evernote(self.note, cloud_note_data)
          self.undirtify
        end
      end

      rescue Evernote::EDAM::Error::EDAMUserException => error
        self.max_out_sync_retries
        sync_error('evernote', guid, nickname, "User Exception: #{ Settings.evernote.errors[error.errorCode] } (#{ error.parameter }).")

      rescue Evernote::EDAM::Error::EDAMNotFoundException => error
        self.max_out_sync_retries
        sync_error('evernote', guid, nickname, "Not Found Exception: #{ error.identifier }: #{ error.key }.")

      rescue Evernote::EDAM::Error::EDAMSystemException
        sync_error('evernote', guid, nickname, "User Exception: error #{ error.errorCode }: #{ error.message }.")
    end

    def update_with_evernote(note, note_data)
      self.update_attributes!(
        :note_id => note.id,
        :sync_retries => 0,
        :content_hash => note_data.contentHash,
        :dirty => false
      )
    end

    def evernote_notebook_required?(note_metadata)
      !Settings.evernote.notebooks.include?(note_metadata.notebookGuid)
    end

    def evernote_note_inactive?(note_metadata)
      !note_metadata.active
    end

    def evernote_note_required?(cloud_note_tags)
      (Settings.evernote.instructions.required & cloud_note_tags) != Settings.evernote.instructions.required
    end

    def evernote_note_ignore?(cloud_note_tags)
      !(Settings.evernote.instructions.ignore & cloud_note_tags).empty?
    end

    def evernote_note_updated?(note_metadata)
      note && note.external_updated_at >= Time.at(note_metadata.updated / 1000).to_datetime
    end

    def evernote_update_note_data(note_metadata, note_store, oauth_token, guid)
      if note_metadata.contentHash == self.content_hash
        note_data = note_metadata
        note_data.content = note.body
      else
        note_data = note_store.getNote(oauth_token, guid, true, false, false, false)
        note_data.content = ActionController::Base.helpers.sanitize(Nokogiri::XML(note_data.content).css("en-note").inner_html,
          :tags => Settings.notes.allowed_html_tags,
          :attributes => Settings.notes.allowed_html_attributes)
      end
      note_data
    end
end
