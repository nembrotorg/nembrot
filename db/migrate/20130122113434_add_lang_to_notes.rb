class AddLangToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :lang, :string, :limit => 2
  end
end
