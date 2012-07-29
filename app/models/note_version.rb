class NoteVersion < ActiveRecord::Base
  attr_accessible :body, :title, :note_id, :version, :external_note_id
  belongs_to :note
  
  attr_writer :external_note_id

# validates :note_id, :presence => true
# we may not know it at this stage
  validates :title, :presence => true
  validates :body, :presence => true

  before_create :get_note_id
  before_create :calculate_version

  def get_note_id
    self.note_id = Note.where(:external_note_id => @external_note_id).first_or_create.id
  end

  # To calculate the version we count how many versions of this note_id already exist, then increment:
  def calculate_version
    self.version = NoteVersion.where(:note_id => self.note_id).count + 1
  end

end
