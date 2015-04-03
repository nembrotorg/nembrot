class AddContentTypeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :content_type, :integer, default: 0, null: false

    Note.all.each do |n|
      if n.is_citation?
        n.content_type = 1
        n.save!
      end
    end
  end
end
