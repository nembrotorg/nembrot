class RenameBooksFullTextToFullTextUrl < ActiveRecord::Migration
  def change
    rename_column :books, :full_text, :full_text_url
  end
end
