class CreateLinksTable < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string  :title
      t.string  :website_name
      t.string  :author
      t.string  :lang
      t.date    :modified
      t.string  :url
      t.string  :canonical_url
      t.boolean :error
      t.boolean :paywall
      t.string  :publisher
      t.boolean :dirty
      t.integer :attempts
      t.timestamps
    end
  end
end
