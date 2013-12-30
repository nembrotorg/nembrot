class DropEvernoteAuthsTable < ActiveRecord::Migration
  def change
    drop_table :evernote_auths
  end
end
