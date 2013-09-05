class AddSequenceToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :sequence, :integer
  end
end
