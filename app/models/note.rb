class Note < ActiveRecord::Base
  attr_accessible :external_identifier, :note_versions_attributes

  has_many :note_versions, :dependent => :destroy

  accepts_nested_attributes_for :note_versions, :reject_if => proc { |a| a['title'].blank? || a['body'].blank? }

  validates :external_identifier, :presence => true, :uniqueness => true

	#There are cases during testing when a note is created before any versions
  #validate :has_version?
	#def has_version?
	#  errors.add "Note must have at least one NoteVersion." if self.note_versions.blank?
	#end

end
