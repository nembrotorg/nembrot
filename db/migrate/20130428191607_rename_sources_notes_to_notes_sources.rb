class RenameSourcesNotesToNotesSources < ActiveRecord::Migration
  def up
    rename_table :sources_notes, :notes_sources
  end

  def down
    rename_table :notes_sources, :sources_notes
  end
end
