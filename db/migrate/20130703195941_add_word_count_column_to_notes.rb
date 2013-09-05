class AddWordCountColumnToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :word_count, :integer
  end
end
