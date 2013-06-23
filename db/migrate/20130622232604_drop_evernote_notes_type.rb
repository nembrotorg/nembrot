class DropEvernoteNotesType < ActiveRecord::Migration
  def change
    remove_column :evernote_notes, :type
  end
end
