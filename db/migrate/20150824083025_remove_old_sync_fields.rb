class RemoveOldSyncFields < ActiveRecord::Migration
  def up
    remove_column :books, :attempts
    remove_column :books, :dirty
    remove_column :books, :try_again_at
    remove_column :evernote_notes, :try_again_at
    remove_column :evernote_notes, :attempts
    remove_column :evernote_notes, :dirty
    remove_column :resources, :attempts
    remove_column :resources, :dirty
    remove_column :resources, :try_again_at
  end

  def down
    add_column :books, :attempts, :integer
    add_column :books, :dirty, :boolean
    add_column :books, :try_again_at, :datetime
    add_column :evernote_notes, :attempts, :integer
    add_column :evernote_notes, :dirty, :boolean
    add_column :evernote_notes, :try_again_at, :datetime
    add_column :resources, :attempts, :integer
    add_column :resources, :dirty, :boolean
    add_column :resources, :try_again_at, :datetime
  end
end
