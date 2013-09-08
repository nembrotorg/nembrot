class DropPantographersPantgraphsId < ActiveRecord::Migration
  def change
    remove_column :pantographers, :pantographs_id
  end
end
