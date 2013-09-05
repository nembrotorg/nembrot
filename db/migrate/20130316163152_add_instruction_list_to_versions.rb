class AddInstructionListToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :instruction_list, :string
  end
end
