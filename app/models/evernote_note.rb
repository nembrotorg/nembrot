# encoding: utf-8

class EvernoteNote < ActiveRecord::Base
  include Evernotable, Syncable

  # REVIEW: , dependent: :destroy (causes Stack Level Too Deep.)
  #  See: http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html ("Options" ... ":dependent") )
  belongs_to :note

  # REVIEW: We don't validate for the presence of note since we want to be able to create dirty CloudNotes
  #  which may then be deleted. Creating a large number of superfluous notes would unnecessarily
  #  inflate the id number of each 'successful' note.
  validates :cloud_note_identifier, presence: true, uniqueness: true
  validates :note_id, uniqueness: true, allow_nil: true

  # validates_associated :note

  def self.add_task(guid, notebook_guid)
    # This test is repeated in EvernoteRequest, and below in #evernote_auth - do we need all of them?
    evernote_note = where(cloud_note_identifier: guid).first_or_initialize
    if !NB.evernote_notebooks.include? notebook_guid
      SYNC_LOG.error "Note is not in any required notebook! (Notebook #{ notebook_guid } is not in #{ NB.evernote_notebooks }."
      evernote_note.note.destroy! unless evernote_note.note.nil?
    else
      evernote_note.update_attribute('cloud_notebook_identifier', notebook_guid)
      evernote_note.dirtify(true)
      SyncNoteJob.perform_later(evernote_note)
    end
  end

  def self.sync_all
    need_syncdown.each do |evernote_note|
      EvernoteRequest.new.sync_down(evernote_note)
    end
  end

  def self.bulk_sync
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(
      notebookGuid: NB.evernote_notebooks,
      words: NB.instructions_required.gsub(/^/, 'tag:').gsub(/ /, ' tag:'),
      order: 2,
      ascending: false
    )
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new

    evernote_notes = evernote_auth.note_store.findNotesMetadata(evernote_auth.oauth_token, filter, 0, 999, spec)
    evernote_notes.notes.each { |evernote_note| EvernoteNote.add_task(evernote_note.guid) }
  end

  def evernote_auth
    EvernoteAuth.new
  end

  private

  def guid
    cloud_note_identifier
  end
end
