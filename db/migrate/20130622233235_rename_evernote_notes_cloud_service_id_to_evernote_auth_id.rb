class RenameEvernoteNotesCloudServiceIdToEvernoteAuthId < ActiveRecord::Migration
  def change
    rename_column :evernote_notes, :cloud_service_id, :evernote_auth_id
  end
end
