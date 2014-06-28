class AddStillMoreAdvancedOptionsToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :notes_index, :boolean, default: true
    add_column :channels, :read_more_notes, :integer, default: 10
  end
end
