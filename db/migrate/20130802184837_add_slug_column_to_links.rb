class AddSlugColumnToLinks < ActiveRecord::Migration
  def change
    add_column :links, :slug, :string
    add_index :links, :slug, unique: true
  end
end
