class Note < ActiveRecord::Base
  attr_accessible :external_note_id

  validates	:external_note_id, :presence => true
end
