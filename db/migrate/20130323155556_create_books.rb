class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.string :translator
      t.string :introducer
      t.string :editor
      t.string :lang
      t.date :published_date
      t.string :published_city
      t.string :publisher
      t.string :isbn_10
      t.string :isbn_13
      t.string :format
      t.integer :page_count
      t.string :dimensions
      t.string :weight
      t.string :google_books_id
      t.string :tag
      t.boolean :dirty
      t.integer :attempts
      t.timestamps
    end
  end
end
