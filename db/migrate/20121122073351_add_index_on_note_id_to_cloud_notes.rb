class AddIndexOnNoteIdToCloudNotes < ActiveRecord::Migration
  def change
    add_index :cloud_notes, :note_id
  end
end
