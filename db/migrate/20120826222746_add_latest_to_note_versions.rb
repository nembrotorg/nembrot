class AddLatestToNoteVersions < ActiveRecord::Migration
  def change
    add_column :note_versions, :latest, :boolean, :default => true
  end
end
