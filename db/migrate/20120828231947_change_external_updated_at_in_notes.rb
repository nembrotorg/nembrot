class ChangeExternalUpdatedAtInNotes < ActiveRecord::Migration
  def up
  	change_column :notes, :external_updated_at, :datetime, :null => false
  end
  def down
  	change_column :notes, :external_updated_at, :datetime
  end
end
