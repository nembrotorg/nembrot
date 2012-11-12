class Note < ActiveRecord::Base
  include ApplicationHelper

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

  before_save :normalise_title

  def normalise_title
    if ['', 'Untitled', 'New note'].include? self.title
      self.title = snippet( self.body, 8)
    end
  end

  def blurb
    if self.body.index(self.title.gsub(/\.\.\.$/, '')) == 0
      self.body
    else
      self.title + ': ' + self.body
    end
  end

  def diffed_version(sequence)
    if sequence == 1
      version = self.versions.find_by_sequence(1).reify
      previous = OpenStruct.new({
        :title => '',
        :body => ''
      })
      version_tags = version.version.tags
      previous_tags = Array.new
    elsif sequence == self.versions.length + 1
      version = self
      previous = self.versions.last.reify
      version_tags = version.tags
      previous_tags = previous.version.tags
    else        
      version = self.versions.find_by_sequence(sequence).reify
      previous = version.previous_version    
      version_tags = version.version.tags
      previous_tags = previous.version.tags
    end

    added_tags = (version_tags - previous_tags).each { |tag| tag.diff_status = 1 }
    removed_tags = (previous_tags - version_tags).each { |tag| tag.diff_status = -1 }
    unchanged_tags = (version_tags - added_tags - removed_tags)
    tags = (added_tags + removed_tags + unchanged_tags).each { |tag|
      if Note.tagged_with(tag.name).size == 0
        tag.obsolete = true
      end 
    }.sort_by { |tag| tag.name.downcase }

    OpenStruct.new({
            :title => version.title,
            :body => version.body,
            :previous_title => previous.title,
            :previous_body => previous.body,
            :sequence => sequence,
            :external_updated_at => version.external_updated_at,
            :tags => tags
          })
  end
end
