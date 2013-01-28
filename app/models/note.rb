class Note < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang,
  :author, :last_edited_by, :source, :source_application, :source_url, :tag_list, :instruction_list

  attr_writer :tag_list, :instruction_list

  has_many :cloud_notes, :dependent => :destroy
  has_many :resources, :dependent => :destroy

  acts_as_taggable_on :tags, :instructions
  acts_as_gmappable :process_geocoding => false, :check_process => false

  has_paper_trail :on => [:update],
                  :meta => {
                    # Adding a sequence enables us to retrieve by version number
                    :sequence  => Proc.new { |note| note.versions.length + 1 },
                    # Simply storing note.tag_list would store incoming tag list
                    :tags  => Proc.new { |note| Note.find(note.id).tags }
                    # SHould instructions be stored for versions?
                  }

  accepts_nested_attributes_for :cloud_notes,
                                :reject_if => Proc.new { |a| a['cloud_note_identifier'].blank? || a['cloud_service'].blank? }

  accepts_nested_attributes_for :resources,
                                :reject_if => Proc.new { |a| a['cloud_resource_identifier'].blank? }

  default_scope :order => 'external_updated_at DESC'

  validates :title, :body, :external_updated_at, :presence => true

  # Being activated on create and throws error
  # validate :external_updated_at_must_be_latest, :before => :update

  before_save :normalise_title

  def blurb
    # If the title is derived from the body, we do not include it in the blurb
    if self.body.index(self.title.gsub(/\.\.\.$/, '')) == 0
      self.body
    else
      self.title + ': ' + self.body
    end
  end

  def diffed_version(sequence)
    if sequence == 1
      # If retrieveing the first version, we create an empty version object and an empty array
      # to enable to diff against them
      version = self.versions.find_by_sequence(1).reify
      previous = OpenStruct.new({
        :title => '',
        :body => ''
      })
      version_tags = version.version.tags
      previous_tags = Array.new
    elsif sequence == self.versions.length + 1
      # If we're requesting the latest (current) version, we select the current note as the
      # version, and the last stored version as previous
      version = self
      previous = self.versions.last.reify
      version_tags = self.tags
      previous_tags = previous.version.tags
    else
      version = self.versions.find_by_sequence(sequence).reify
      previous = version.previous_version
      version_tags = version.version.tags
      previous_tags = previous.version.tags
    end

    # We calculate the difference between current and previous tag lists,
    # and set diff_status accordingly so we can mark up list in view
    added_tags = (version_tags - previous_tags).each { |tag| tag.diff_status = 1 }
    removed_tags = (previous_tags - version_tags).each { |tag| tag.diff_status = -1 }
    unchanged_tags = (version_tags - added_tags - removed_tags)
    tags = (added_tags + removed_tags + unchanged_tags)

    # We check whether tags are still in use and set obsolete accordingly
    tags.each { |tag|
      if Note.tagged_with(tag.name).size == 0
        tag.obsolete = true
      end
    }

    tags.sort_by { |tag| tag.name.downcase }

    # We build and return the version object
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

  # private
    # def external_updated_at_must_be_latest
    #     if !self.external_updated_at_was.nil? && self.external_updated_at <= self.external_updated_at_was
    #       errors.add( :external_updated_at, 'must be more recent than any other version' )
    #       return false
    #     end
    # end

    def normalise_title
      # Title can be normalised on access (versions can save normalised title or
      # save it as headline, or not save it at all and recalculated in diffed_version...)
      # This could lead to a false diffing though, if title is modified in note on the basis
      # of the headline at the time.
      if I18n.t('notes.untitled_synonyms').include? self.title
        self.title = snippet( self.body, Settings.notes.title_length )
      end
    end

    def embedded_source_url
      if self.source_url
        self.source_url
          .gsub(/^.*youtube.*v=(.*)\b/, "http://www.youtube.com/embed/\\1?rel=0")
          .gsub(/^.*vimeo\/video\/(\d*)\b/, "http://player.vimeo.com/video/\\1")
          .gsub(/(^.*soundcloud.*$)/, "http://w.soundcloud.com/player/?url=\\1")
      else
        nil
      end
    end

    def gmaps4rails_title
      self.title
    end

    def gmaps4rails_infowindow
      image_path = "/resources/cut/#{ self.resources.attached_images.first.cloud_resource_identifier }-16-9-160.jpeg"
      "<img src=\"#{ image_path }\" width=\160\" height=\"90\"><br>#{self.title}"
    end
end
