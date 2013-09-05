class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :id_evernote

      t.timestamps
    end
  end
end
