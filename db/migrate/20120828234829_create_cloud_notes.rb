class CreateCloudNotes < ActiveRecord::Migration
  def change
    create_table :cloud_notes do |t|
      t.string :cloud_note_identifier

      t.belongs_to :note
      t.belongs_to :cloud_service

      t.timestamps
    end
  end
end
