class AddBooleanFieldsToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :is_feature, :boolean
    add_column :notes, :is_section, :boolean
    add_column :notes, :is_mapped, :boolean
    add_column :notes, :is_promoted, :boolean
  end
end
