class AddAuthToCloudServices < ActiveRecord::Migration
  def change
    add_column :cloud_services, :auth, :text
  end
end
