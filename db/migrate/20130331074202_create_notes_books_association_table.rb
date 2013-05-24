class CreateNotesBooksAssociationTable < ActiveRecord::Migration
  def change
    create_table :books_notes do |t|
      t.references :book
      t.references :note
    end
  end
end
