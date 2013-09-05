class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :cloud_resource_identifier
      t.string :mime
      t.string :caption
      t.string :description
      t.string :credit
      t.string :source_url
      t.datetime :external_updated_at
      t.float :latitude
      t.float :longitude
      t.float :altitude
      t.string :camera_make
      t.string :camera_model
      t.string :file_name
      t.boolean :attachment
      t.boolean :dirty
      t.integer :sync_retries

      t.belongs_to :note

      t.timestamps
    end
  end
end
