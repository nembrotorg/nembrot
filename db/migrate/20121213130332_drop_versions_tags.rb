class DropVersionsTags < ActiveRecord::Migration
  def change
    remove_column :versions, :tags
  end
end
