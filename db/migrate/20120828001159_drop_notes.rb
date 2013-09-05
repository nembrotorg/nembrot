class DropNotes < ActiveRecord::Migration
  def up
    drop_table :notes
  end

  def down
    create_table :notes do |t|
      t.string :id_evernote

      t.timestamps
  	end
	end
end
