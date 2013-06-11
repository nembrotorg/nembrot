class AddFieldsToSources < ActiveRecord::Migration
  def change
    add_column :sources, :dewey_decimal, :string
    add_column :sources, :lcc_number, :string
    add_column :sources, :full_text, :string
    add_column :sources, :google_books_embeddable, :boolean
  end
end
