class AddContentTypeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :content_type, :integer, default: 0, null: false

    Note.all.each do |note|
      if note.is_citation?
        note.content_type = 1
        note.save!
      end
    end
  end
end
