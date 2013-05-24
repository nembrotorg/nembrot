class RenameSourcesIndexBooksOnSlug < ActiveRecord::Migration
  def up
    remove_index :sources, :name => :index_books_on_slug
    add_index "sources", ["slug"], :name => "index_sources_on_slug", :unique => true
  end

  def down
    remove_index :sources, :name => :index_sources_on_slug
    add_index "sources", ["slug"], :name => "index_books_on_slug", :unique => true
  end
end
