class MakeNotesExternalNoteIdRequired < ActiveRecord::Migration
  def change
  	change_column :notes, :external_note_id, :string, :null => false
  end
end
