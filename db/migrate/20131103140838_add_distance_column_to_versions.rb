class AddDistanceColumnToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :distance, :integer
  end
end
