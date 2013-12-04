class AddFeatureAndFeatureIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :feature, :string
    add_column :notes, :feature_id, :string
  end
end
