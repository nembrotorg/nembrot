class AddGeoColumnsToLinks < ActiveRecord::Migration
  def change
    add_column :links, :latitude, :float
    add_column :links, :longitude, :float
    add_column :links, :altitude, :float
  end
end
