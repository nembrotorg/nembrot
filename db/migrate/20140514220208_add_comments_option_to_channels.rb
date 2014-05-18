class AddCommentsOptionToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :comments, :boolean, default: true
  end
end
