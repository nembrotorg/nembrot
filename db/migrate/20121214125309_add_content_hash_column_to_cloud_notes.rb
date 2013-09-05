class AddContentHashColumnToCloudNotes < ActiveRecord::Migration
  def change
    add_column :cloud_notes, :content_hash, :string
  end
end
