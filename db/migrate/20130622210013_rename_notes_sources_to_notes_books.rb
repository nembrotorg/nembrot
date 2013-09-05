class RenameNotesSourcesToNotesBooks < ActiveRecord::Migration
  def change
    rename_table :notes_sources, :notes_books
  end
end
