class DropEvernoteAuthIdColumnFromEvernoteNotes < ActiveRecord::Migration
  def change
    remove_column :evernote_notes, :evernote_auth_id
  end
end
