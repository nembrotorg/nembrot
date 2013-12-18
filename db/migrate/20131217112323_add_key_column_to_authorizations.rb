class AddKeyColumnToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :key, :text
  end
end
