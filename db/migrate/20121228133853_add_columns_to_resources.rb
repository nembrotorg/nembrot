class AddColumnsToResources < ActiveRecord::Migration
  def change
    add_column :resources, :data_hash, :binary
    add_column :resources, :width, :integer
    add_column :resources, :height, :integer
    add_column :resources, :size, :integer
  end
end
