class RenameEvernoteNotesIndex < ActiveRecord::Migration
  def change
    rename_index :evernote_notes, :index_cloud_notes_on_cloud_note_id_and_cloud_service_id, :index_cloud_notes_on_cloud_note_identifier
  end
end
