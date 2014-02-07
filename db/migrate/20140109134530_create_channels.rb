class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.string :theme
      t.text :notebooks
      t.belongs_to :user

      t.timestamps
    end
  end
end