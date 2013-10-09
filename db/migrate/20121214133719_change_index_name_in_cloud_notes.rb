# class ChangeIndexNameInCloudNotes < ActiveRecord::Migration
#   def up
#     rename_index :cloud_notes, 'index_cloud_notes_on_cloud_note_identifier_and_cloud_service_id', 'index_cloud_notes_on_identifier_service_id'
#   end

#   def down
#     rename_index :cloud_notes, 'index_cloud_notes_on_identifier_service_id', 'index_cloud_notes_on_cloud_note_identifier_and_cloud_service_id'
#   end
# end
