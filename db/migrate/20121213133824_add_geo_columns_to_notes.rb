class AddGeoColumnsToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :latitude, :float
    add_column :notes, :longitude, :float
    add_column :notes, :altitude, :float
  end
end
