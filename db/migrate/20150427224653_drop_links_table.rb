class DropLinksTable < ActiveRecord::Migration
  def up
    drop_table :links
  end
  def down
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
      t.float   :latitude
      t.float   :longitude
      t.float   :altitude
      t.string  :channel
      t.string  :slug
      t.datetime :try_again_at
      t.timestamps
    end
    add_index :links, :slug, unique: true
  end
end
