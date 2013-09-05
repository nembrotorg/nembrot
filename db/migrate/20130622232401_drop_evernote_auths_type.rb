class DropEvernoteAuthsType < ActiveRecord::Migration
  def change
    remove_column :evernote_auths, :type
  end
end
