class ChangePantographersIdToPantographerId < ActiveRecord::Migration
  def change
    rename_column :pantographs, :pantographers_id, :pantographer_id
  end
end
