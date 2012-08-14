class Note < ActiveRecord::Base
  attr_accessible :external_identifier, :note_versions_attributes

  has_many :note_versions, :dependent => :destroy

  accepts_nested_attributes_for :note_versions, :reject_if => proc { |a| a['title'].blank? || a['body'].blank? }

  validates :external_identifier, :presence => true
  #validates :external_identifier, :presence => true, :uniqueness => true
  #This is fine when used iwth first_or_create as it should be
  #But need a different way of building in FactoryGirl

	#validate :has_version?
	#def has_version?
	#  errors.add "Note must have at least one NoteVersion." if self.note_versions.blank?
	#end

end
