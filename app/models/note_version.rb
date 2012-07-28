class NoteVersion < ActiveRecord::Base
  attr_accessible :body, :title, :note_id, :version
  belongs_to :note
  
# validates :note_id, :presence => true
# we may not know it at this stage
  validates :title, :presence => true
  validates :body, :presence => true
  validates :version, :presence => true

end
