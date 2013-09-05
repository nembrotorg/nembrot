class RenameSourcesToBooks < ActiveRecord::Migration
  def change
    rename_table :sources, :books
  end
end
