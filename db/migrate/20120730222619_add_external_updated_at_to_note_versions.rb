class AddExternalUpdatedAtToNoteVersions < ActiveRecord::Migration
  def change
    add_column :note_versions, :external_updated_at, :datetime
  end
end
