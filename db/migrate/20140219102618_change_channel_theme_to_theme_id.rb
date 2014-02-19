class ChangeChannelThemeToThemeId < ActiveRecord::Migration
  def change
    remove_column :channels, :theme
    add_column :channels, :theme_id, :integer
  end
end
