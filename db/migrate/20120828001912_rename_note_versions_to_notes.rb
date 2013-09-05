class RenameNoteVersionsToNotes < ActiveRecord::Migration
  def up
        rename_table :note_versions, :notes
  end

  def down
        rename_table :notes, :note_versions
  end
end
