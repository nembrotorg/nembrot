class RenameCloudServicesAuthEncryptedToEncryptedAuth < ActiveRecord::Migration
  def change
    rename_column :cloud_services, :auth_encrypted, :encrypted_auth
  end
end
