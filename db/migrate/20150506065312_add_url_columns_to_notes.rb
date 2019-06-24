class AddUrlColumnsToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :url, :string
    add_column :notes, :url_author, :string
    add_column :notes, :url_html, :binary
    add_column :notes, :url_lede, :text
    add_column :notes, :url_title, :string
    add_column :notes, :url_updated_at, :datetime
    add_column :notes, :url_accessed_at, :datetime
  end
end
