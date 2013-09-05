class AddExternalUpdatedAtToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :external_updated_at, :datetime
  end
end
