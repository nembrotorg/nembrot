class ChangeVersionsInstructionList < ActiveRecord::Migration
  def up
    rename_column :versions, :instruction_list, :instructions
    change_column :versions, :instructions, :text
  end

  def down
    change_column :versions, :instructions, :string
    rename_column :versions, :instructions, :instruction_list
  end
end
