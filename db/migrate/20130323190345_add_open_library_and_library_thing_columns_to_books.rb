class AddOpenLibraryAndLibraryThingColumnsToBooks < ActiveRecord::Migration
  def change
    add_column :books, :library_thing_id, :string
    add_column :books, :open_library_id, :string
  end
end
