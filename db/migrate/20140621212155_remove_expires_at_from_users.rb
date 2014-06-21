class RemoveExpiresAtFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :expires_at
  end

  def down
    add_column :users, :expires_at, :datetime
  end
end
