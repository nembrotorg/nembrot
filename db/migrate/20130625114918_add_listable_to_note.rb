class AddListableToNote < ActiveRecord::Migration
  def change
    add_column :notes, :listable, :boolean, default: true
  end
end
