class RenameSourcesNotesBookIdToSourceId < ActiveRecord::Migration
  def change
    rename_column :sources_notes, :book_id, :source_id
  end
end
