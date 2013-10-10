class ChangeCloudNotesContentHashToBinary < ActiveRecord::Migration
  def up
    remove_column :cloud_notes, :content_hash, :string
    add_column :cloud_notes, :content_hash, :binary
  end

  def down
    remove_column :cloud_notes, :content_hash, :binary
    add_column :cloud_notes, :content_hash, :string
  end
end
