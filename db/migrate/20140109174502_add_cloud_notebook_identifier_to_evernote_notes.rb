class AddCloudNotebookIdentifierToEvernoteNotes < ActiveRecord::Migration
  def change
    add_column :evernote_notes, :cloud_notebook_identifier, :text
  end
end
