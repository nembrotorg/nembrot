class AddWeightToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :weight, :integer
  end
end
