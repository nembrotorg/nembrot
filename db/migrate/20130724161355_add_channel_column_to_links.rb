class AddChannelColumnToLinks < ActiveRecord::Migration
  def change
    add_column :links, :channel, :string
  end
end
