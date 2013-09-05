class AddHideColumnToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :hide, :boolean
  end
end
