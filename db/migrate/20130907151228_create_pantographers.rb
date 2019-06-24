class CreatePantographers < ActiveRecord::Migration
  def change
    create_table :pantographers do |t|
      t.string :twitter_screen_name
      t.string :twitter_real_name
      t.integer :twitter_user_id

      t.belongs_to :pantographs

      t.timestamps
    end
  end
end
