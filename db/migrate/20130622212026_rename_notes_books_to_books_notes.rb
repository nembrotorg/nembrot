class RenameNotesBooksToBooksNotes < ActiveRecord::Migration
  def change
    rename_table :notes_books, :books_notes
  end
end
