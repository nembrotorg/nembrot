class Note < ActiveRecord::Base
  attr_accessible :title, :body, :external_updated_at, :tag_list

  has_many :cloud_notes, :dependent => :destroy

  acts_as_taggable
  
	has_paper_trail :on => [:update, :destroy],
									:meta => { 
										:sequence  => Proc.new { |note| note.versions.length + 1 }, 
										:tags  => Proc.new { |note| Note.find(note.id).tags } # Simply storing note.tag_list would store incoming one, so we store object
									}

  accepts_nested_attributes_for :cloud_notes, 
  															:reject_if => Proc.new { |a| a['cloud_note_identifier'].blank? || a['cloud_service'].blank? }

  validates :title, :body, :external_updated_at, :presence => true
end
