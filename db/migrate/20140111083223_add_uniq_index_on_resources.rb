class AddUniqIndexOnResources < ActiveRecord::Migration
  def change
    add_index :resources, [:cloud_resource_identifier, :note_id], unique: true
  end
end
