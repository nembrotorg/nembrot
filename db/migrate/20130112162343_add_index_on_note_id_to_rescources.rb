class AddIndexOnNoteIdToRescources < ActiveRecord::Migration
  def change
    add_index :resources, :note_id
  end
end
