class RenameNotesIdEvernote < ActiveRecord::Migration
  def change
  	rename_column :notes, :id_evernote, :external_note_id
  end
end
