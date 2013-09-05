class RenameBooksNotesToSourcesNotes < ActiveRecord::Migration
  def up
    rename_table :books_notes, :sources_notes
  end

  def down
    rename_table :sources_notes, :books_notes
  end
end
