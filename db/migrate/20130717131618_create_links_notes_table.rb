class CreateLinksNotesTable < ActiveRecord::Migration
  def change
    create_table :links_notes do |t|
      t.integer :link_id
      t.integer :note_id
    end
  end
end
