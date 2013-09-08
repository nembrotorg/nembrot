class RenamePantographersTwitterUserNameTwitterScreenName < ActiveRecord::Migration
  def change
    rename_column :pantographers, :twitter_screen_name, :twitter_screen_name
  end
end
