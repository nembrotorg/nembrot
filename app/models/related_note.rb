class RelatedNote < ActiveRecord::Base
  belongs_to :note
  belongs_to :related_note, class_name: "Note"
end
