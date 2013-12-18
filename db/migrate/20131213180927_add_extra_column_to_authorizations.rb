class AddExtraColumnToAuthorizations < ActiveRecord::Migration
  def change
    add_column :authorizations, :extra, :text
  end
end
