class DropUserEmailPasswordColumns < ActiveRecord::Migration
  def change
    remove_column :users, :email
    remove_column :users, :encrypted_password
  end
end
