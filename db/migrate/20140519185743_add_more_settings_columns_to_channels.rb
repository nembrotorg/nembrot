class AddMoreSettingsColumnsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :active, :boolean, default: true
    add_column :channels, :breadcrumbs, :boolean, default: true
    add_column :channels, :menu_at_top, :boolean, default: false
    add_column :channels, :menu_at_bottom, :boolean, default: true
  end
end
