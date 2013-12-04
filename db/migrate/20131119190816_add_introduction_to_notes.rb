class AddIntroductionToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :introduction, :text
  end
end
