class AddUpdateSequenceNumberToCloudNotes < ActiveRecord::Migration
  def change
    add_column :cloud_notes, :update_sequence_number, :integer
  end
end
