class AddColumnsToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :active, :boolean
    add_column :notes, :author, :string
    add_column :notes, :source, :string
    add_column :notes, :source_url, :string
    add_column :notes, :source_application, :string
    add_column :notes, :last_edited_by, :string
  end
end
