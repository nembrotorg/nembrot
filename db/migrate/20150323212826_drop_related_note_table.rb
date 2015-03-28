class DropRelatedNoteTable < ActiveRecord::Migration
  def change
    drop_table :related_notes
  end
end
