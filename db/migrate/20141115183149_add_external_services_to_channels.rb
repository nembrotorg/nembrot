class AddExternalServicesToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :follow_on_github, :string
    add_column :channels, :follow_on_instagram, :string
    add_column :channels, :follow_on_pinterest, :string
    add_column :channels, :follow_on_flickr, :string
  end
end
