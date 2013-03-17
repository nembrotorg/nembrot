class RenameCloudNotesSyncRetries < ActiveRecord::Migration
  def change
    rename_column :cloud_notes, :sync_retries, :attempts
  end
end
