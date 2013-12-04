class RenameAuthorizationsUsernameToNickname < ActiveRecord::Migration
  def change
    rename_column :authorizations, :username, :nickname
  end
end
