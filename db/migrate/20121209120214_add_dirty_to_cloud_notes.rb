class AddDirtyToCloudNotes < ActiveRecord::Migration
  def change
    add_column :cloud_notes, :dirty, :boolean
  end
end
