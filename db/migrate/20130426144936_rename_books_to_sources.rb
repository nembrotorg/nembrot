class RenameBooksToSources < ActiveRecord::Migration
  def up
    rename_table :books, :sources
  end

  def down
    rename_table :sources, :books
  end
end
