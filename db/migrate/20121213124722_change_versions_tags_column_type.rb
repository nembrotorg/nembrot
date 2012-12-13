class ChangeVersionsTagsColumnType < ActiveRecord::Migration
  def up
    change_column :versions, :tags, :text
  end

  def down
    change_column :versions, :tags, :string
  end
end
