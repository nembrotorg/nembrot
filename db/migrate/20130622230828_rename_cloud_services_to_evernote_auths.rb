class RenameCloudServicesToEvernoteAuths < ActiveRecord::Migration
  def change
    rename_table :cloud_services, :evernote_auths
  end
end
