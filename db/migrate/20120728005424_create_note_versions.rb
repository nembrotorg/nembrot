class CreateNoteVersions < ActiveRecord::Migration
  def change
    create_table :note_versions do |t|
      t.string :title, 		:null => false
      t.text :body, 		:null => false
      t.integer :version, 	:null => false

      t.timestamps
    end
  end
end
