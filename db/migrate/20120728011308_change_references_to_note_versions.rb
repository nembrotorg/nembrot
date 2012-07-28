class ChangeReferencesToNoteVersions < ActiveRecord::Migration
  def up
    change_table :note_versions do |t|
      t.references :note
    end
  end
  def down
    t.remove :note_id
  end
end
