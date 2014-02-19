class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.boolean :premium
      t.boolean :public
      t.string :effects
      t.string :map_style
      t.string :name
      t.string :slug
      t.string :typekit_code
      t.boolean :suitable_for_text
      t.boolean :suitable_for_images
      t.boolean :suitable_for_maps
      t.boolean :suitable_for_video_and_sound

      t.timestamps
    end
  end
end
