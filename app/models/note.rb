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

  def headline
    self.title + ': ' + self.body
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

    OpenStruct.new({
            :title => Differ.diff_by_word(version.title, previous.title),
            :body => Differ.diff_by_word(version.body, previous.body),
            :undiffed_title => version.title,
            :undiffed_body => version.body,
            :sequence => sequence,
            :external_updated_at => version.external_updated_at,
            :removed_tags => previous_tags - version_tags,
            :added_tags => version_tags - previous_tags,
            :tags => (version_tags + previous_tags).find_all { |tag| tag.name.match(/^[^_]/) }.uniq.sort_by { |tag| tag.name.downcase }
          })
  end

end
