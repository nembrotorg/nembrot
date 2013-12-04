class CreateRelatedNotesTable < ActiveRecord::Migration
  create_table :related_notes, force: true do |t|
    t.integer  :note_id
    t.integer  :related_note_id
    t.datetime :created_at
    t.datetime :updated_at
  end
end
