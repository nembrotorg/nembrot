class ChangePantographersTwitterIdsToBigint < ActiveRecord::Migration
  def change
    remove_column :pantographers, :twitter_user_id
    add_column :pantographers, :twitter_user_id, :integer, limit: 8
  end
end
