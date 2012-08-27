class NoteVersion < ActiveRecord::Base
  attr_accessible :body, :title, :version, :external_updated_at

  belongs_to :note

  acts_as_taggable

  scope :current, :conditions => { :latest => true },
                  :order => 'external_updated_at DESC'

  before_validation :set_latest, :calculate_version

  validates :title, :body, :external_updated_at, :version, :note_id, :presence => true
  validate :external_updated_at_must_be_latest, :before => :save
  validates_associated :note

  # Sets :latest in all other versions to false
  def set_latest
    NoteVersion.update_all( { :latest => false }, { :note_id => self.note_id } )
    self.latest = true
  end

  # To calculate the version we count how many versions of this note_id already exist, then increment:
  def calculate_version
    self.version = NoteVersion.where( :note_id => self.note_id ).count + 1
  end

  def external_updated_at_must_be_latest
    if self.version > 1 and !( self.external_updated_at > NoteVersion.where( :note_id => self.note_id ).maximum( :external_updated_at ) )
      errors.add( :external_updated_at, 'must be more recent than any other version' )
    end
  end
end
