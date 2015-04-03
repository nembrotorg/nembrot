class AddContentTypeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :content_type, :integer, default: 0, null: false
  end
end
