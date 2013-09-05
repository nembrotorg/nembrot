class RenameVersionsTagListColumnToTags < ActiveRecord::Migration
  def change
    rename_column :versions, :tag_list, :tags
  end
end
