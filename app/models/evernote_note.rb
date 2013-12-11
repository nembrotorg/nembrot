# encoding: utf-8

class EvernoteNote < ActiveRecord::Base

  include Evernotable
  include Syncable

  # REVIEW: , dependent: :destroy (causes Stack Level Too Deep.
  #  See: http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html ("Options" ... ":dependent") )
  belongs_to :note
  belongs_to :evernote_auth

  # REVIEW: We don't validate for the presence of note since we want to be able to create dirty CloudNotes
  #  which may then be deleted. Creating a large number of superfluous notes would unnecessarily
  #  inflate the id number of each 'successful' note.
  validates :evernote_auth, presence: true
  validates :cloud_note_identifier, presence: true, uniqueness: { scope: :evernote_auth_id }

  validates_associated :note, :evernote_auth

  def self.add_task(guid)
    evernote_note = where(cloud_note_identifier: guid).first_or_create
    evernote_note.evernote_auth_id = evernote_auth.id
    evernote_note.dirtify
  end

  def self.sync_all
    need_syncdown.each do |evernote_note|
      EvernoteRequest.new.sync_down(evernote_note)
    end
  end

  def self.bulk_sync
    filter = Evernote::EDAM::NoteStore::NoteFilter.new(
      notebookGuid: Setting['channel.evernote_notebooks'],
      words: Setting['advanced.instructions_required'].gsub(/^/, 'tag:').gsub(/ /, ' tag:'),
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
