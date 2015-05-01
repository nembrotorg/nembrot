class DropLinksNotesTable < ActiveRecord::Migration
  def up
    drop_table :links_notes
  end

  def down
    create_table :links_notes do |t|
      t.integer :link_id
      t.integer :note_id
    end
  end
end
