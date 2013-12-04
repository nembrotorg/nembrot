class AddFirstNameLastNameImageUserColumns < ActiveRecord::Migration
  def change
    add_column    :users, :first_name, :string
    add_column    :users, :last_name, :string
    add_column    :users, :image, :string
    rename_column :users, :username, :nickname
  end
end
