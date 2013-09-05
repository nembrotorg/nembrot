class AddLocalFileNameToResources < ActiveRecord::Migration
  def change
    add_column :resources, :local_file_name, :string
  end
end
