class DropNoteIdVersionsAndLatestFromNotes < ActiveRecord::Migration
  def up
    remove_column :notes, :note_id
    remove_column :notes, :latest
    remove_column :notes, :version
  end
  def down
    add_column 		:notes, :note_id, :integer
    add_column 		:notes, :latest, :boolean, :default => true
    add_column 		:notes, :version, :integer, :default => 1
  end
end
