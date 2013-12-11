class RenamePantographsBodyToText < ActiveRecord::Migration
  def change
    rename_column :pantographs, :body, :text
  end
end
