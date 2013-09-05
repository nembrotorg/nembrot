class RenameVersionsTagsInstructions < ActiveRecord::Migration
  def change
    rename_column :versions, :tags, :tag_list
    rename_column :versions, :instructions, :instruction_list
  end
end
