class AddIsCitationToNote < ActiveRecord::Migration
  def change
    add_column :notes, :is_citation, :boolean, default: false
  end
end
