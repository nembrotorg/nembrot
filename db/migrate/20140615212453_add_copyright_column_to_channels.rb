class AddCopyrightColumnToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :copyright, :text
  end
end
