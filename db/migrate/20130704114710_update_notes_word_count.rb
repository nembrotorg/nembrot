class UpdateNotesWordCount < ActiveRecord::Migration
  def change
    Note.all.each do |n|
      n.save!
    end
  end
end
