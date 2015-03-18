class ChangeResourcesStringColumnsToText < ActiveRecord::Migration
  def change
    change_column :resources, :caption, :text
    change_column :resources, :credit, :text
    change_column :resources, :description, :text
  end
end
