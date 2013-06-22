class RenameNotesBooksSourceIdToBooksId < ActiveRecord::Migration
  def change
    rename_column :notes_books, :source_id, :book_id
  end
end
