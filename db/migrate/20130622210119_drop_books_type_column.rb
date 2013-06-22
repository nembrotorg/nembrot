class DropBooksTypeColumn < ActiveRecord::Migration
  def change
    remove_column :books, :type
  end
end
