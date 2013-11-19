class AddTryAgainAtColumn < ActiveRecord::Migration
  def change
    add_column :books, :try_again_at, :datetime
    add_column :evernote_notes, :try_again_at, :datetime
    add_column :links, :try_again_at, :datetime
    add_column :resources, :try_again_at, :datetime
  end
end
