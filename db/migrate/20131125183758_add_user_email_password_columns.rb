class AddUserEmailPasswordColumns < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    add_column :users, :encrypted_password, :string
  end
end
