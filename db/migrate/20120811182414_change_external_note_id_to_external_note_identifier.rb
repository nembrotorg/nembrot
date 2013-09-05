class ChangeExternalNoteIdToExternalNoteIdentifier < ActiveRecord::Migration
  def change
  	rename_column :notes, :external_note_id, :external_identifier
  end
end
