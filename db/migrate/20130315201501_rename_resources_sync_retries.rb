class RenameResourcesSyncRetries < ActiveRecord::Migration
  def change
    rename_column :resources, :sync_retries, :attempts
  end
end
