class AddDistanceColumnToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :distance, :integer
  end
end
