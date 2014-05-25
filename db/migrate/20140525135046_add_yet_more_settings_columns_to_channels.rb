class AddYetMoreSettingsColumnsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :follow_on_googleplus, :string
    add_column :channels, :newsletter, :boolean, default: true
    add_column :channels, :promoted, :boolean, default: false
    add_column :channels, :tags, :boolean, default: true
    add_column :channels, :locale_auto, :boolean, default: true
  end
end
