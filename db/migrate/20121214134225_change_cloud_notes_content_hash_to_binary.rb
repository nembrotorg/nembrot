class ChangeCloudNotesContentHashToBinary < ActiveRecord::Migration
  def up
    change_column :cloud_notes, :content_hash, :binary
  end

  def down
    change_column :cloud_notes, :content_hash, :string
  end
end
