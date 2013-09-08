class ChangePantographsTwitterIdsToBigint < ActiveRecord::Migration
  def change
    remove_column :pantographs, :tweet_id
    add_column :pantographs, :tweet_id, :integer, limit: 8
  end
end
