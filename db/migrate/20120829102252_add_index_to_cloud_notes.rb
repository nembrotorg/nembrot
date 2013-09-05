class AddIndexToCloudNotes < ActiveRecord::Migration
  def change
 		add_index "cloud_notes", ["cloud_note_identifier", "cloud_service_id"], :name => "index_cloud_notes_on_cloud_note_id_and_cloud_service_id", :unique => true
  end
end
