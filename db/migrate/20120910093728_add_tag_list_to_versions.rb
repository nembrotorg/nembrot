class AddTagListToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :tag_list, :string
  end
end
