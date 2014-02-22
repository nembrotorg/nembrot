class AddCssColumnToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :css, :string
  end
end
