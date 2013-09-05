class AddTagListColumnToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :tag_list, :text
  end
end
