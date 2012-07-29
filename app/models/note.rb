class Note < ActiveRecord::Base
  attr_accessible :external_note_id

  has_many :note_versions, :dependent => :destroy

  validates	:external_note_id, :presence => true
end
