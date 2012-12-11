class AddAuthEncryptedToCloudServices < ActiveRecord::Migration
  def change
    add_column :cloud_services, :auth_encrypted, :text
  end
end
