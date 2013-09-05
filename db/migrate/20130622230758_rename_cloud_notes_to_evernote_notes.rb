class RenameCloudNotesToEvernoteNotes < ActiveRecord::Migration
  def change
    rename_table :cloud_notes, :evernote_notes
  end
end
