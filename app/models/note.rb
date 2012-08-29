class Note < ActiveRecord::Base
  attr_accessible :title, :body, :external_updated_at

  has_many :cloud_notes, :dependent => :destroy

  acts_as_taggable

  accepts_nested_attributes_for :cloud_notes, :reject_if => proc { |a| a['cloud_note_identifier'].blank? || a['cloud_service'].blank? }

  validates :title, :body, :external_updated_at, :presence => true
end
