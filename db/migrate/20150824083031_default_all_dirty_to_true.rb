class DefaultAllDirtyToTrue < ActiveRecord::Migration
  def up
    add_column :books, :dirty, :boolean, default: true
    add_column :evernote_notes, :dirty, :boolean, default: true
    add_column :resources, :dirty, :boolean, default: true
  end

  def down
    remove_column :books, :dirty
    remove_column :evernote_notes, :dirty
    remove_column :resources, :dirty
  end
end
