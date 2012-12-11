class AddSyncRetriesToCloudNotes < ActiveRecord::Migration
  def change
    add_column :cloud_notes, :sync_retries, :integer
  end
end
