class CreatePantographs < ActiveRecord::Migration
  def change
    create_table :pantographs do |t|
      t.string :body, limit: 140
      t.datetime :external_created_at
      t.integer :tweet_id

      t.belongs_to :pantographers

      t.timestamps
    end
  end
end
