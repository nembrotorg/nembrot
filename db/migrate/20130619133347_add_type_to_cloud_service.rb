class AddTypeToCloudService < ActiveRecord::Migration
  def change
    add_column :cloud_services, :type, :string
  end
end
