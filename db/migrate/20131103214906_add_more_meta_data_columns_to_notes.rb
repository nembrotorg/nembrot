class AddMoreMetaDataColumnsToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :place, :string
    add_column :notes, :content_class, :string
  end
end
