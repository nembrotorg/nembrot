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
    need_syncdown.each do |evernote_note|
      EvernoteRequest.new(evernote_note)
    end
  end

  def self.bulk_sync
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(
      notebookGuid: Settings.evernote.notebooks,
      words: Settings.notes.instructions.required.join(' ').gsub(/^/, 'tag:').gsub(/ /, ' tag:'),
      order: 2,
      ascending: false
    )
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    evernote_notes = evernote_auth.note_store.findNotesMetadata(evernote_auth.oauth_token, filter, 0, 999, spec)
    evernote_notes.notes.each { |evernote_note| EvernoteNote.add_task(evernote_note.guid) }
  end

  private

  def self.evernote_auth
    EvernoteAuth.first_or_create
  end

  def guid
    cloud_note_identifier
  end
end
