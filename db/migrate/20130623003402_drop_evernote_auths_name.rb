class DropEvernoteAuthsName < ActiveRecord::Migration
  def change
    remove_column :evernote_auths, :name
  end
end
