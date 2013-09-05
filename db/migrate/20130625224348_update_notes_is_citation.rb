class UpdateNotesIsCitation < ActiveRecord::Migration
  def up
    Note.all.each do |n|
      n.is_citation = n.looks_like_a_citation?(n.text_for_analysis(n.body))
      n.hide = false
      n.listable = true
      n.save
    end
  end

  def down
    Note.all.each do |n|
      n.is_citation = nil
      n.hide = nil
      n.listable = nil
      n.save
    end
  end
end
