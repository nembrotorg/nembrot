class RemoveNewsletterColumnFromChannels < ActiveRecord::Migration
  def up
    remove_column :channels, :newsletter
  end

  def down
    add_column :channels, :newsletter, :boolean, default: true
  end
end
