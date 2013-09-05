class AddTypeToCloudNote < ActiveRecord::Migration
  def change
    add_column :cloud_notes, :type, :string
  end
end
