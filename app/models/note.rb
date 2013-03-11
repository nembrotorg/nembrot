class Note < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang,
  :author, :last_edited_by, :source, :source_application, :source_url, :tag_list, :instruction_list

  attr_writer :tag_list, :instruction_list

  has_many :cloud_notes, :dependent => :destroy
  has_many :resources, :dependent => :destroy

  acts_as_taggable_on :tags, :instructions

  has_paper_trail :on => [:update],
                  :meta => {
                    # Adding a sequence enables us to retrieve by version number
                    :sequence  => Proc.new { |note| note.versions.length + 1 },
                    # Simply storing note.tag_list would store incoming tag list
                    :tags  => Proc.new { |note| Note.find(note.id).tags }
                    # Should instructions be stored for versions?
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
      version = self.versions.first.reify
      previous = OpenStruct.new({
        :title => '',
        :body => '',
        :tags => Array.new
      })
    elsif sequence == self.versions.size + 1
      # If we're requesting the latest (current) version, we select the current note as the
      # version, and the last stored version as previous
      version = self
      previous = self.versions.last.reify
    else
      version = self.versions.find_by_sequence(sequence).reify
      previous = version.previous_version
    end

    # We calculate the difference between current and previous tag lists,
    # and set diff_status accordingly so we can mark up list in view
    added_tags = (version.tags - previous.tags).each { |tag| tag.diff_status = 1 }
    removed_tags = (previous.tags - version.tags).each { |tag| tag.diff_status = -1 }
    unchanged_tags = (version.tags - added_tags - removed_tags)
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
      :embeddable_source_url => version.embeddable_source_url,
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
        # TODO: option
        # self.title = "Note #{ self.id }"
      end
    end

    def embeddable_source_url
      if self.source_url && self.source_url =~ /youtube|vimeo|soundcloud/
        self.source_url
          .gsub(/^.*youtube.*v=(.*)\b/, "http://www.youtube.com/embed/\\1?rel=0")
          .gsub(/^.*vimeo.*\/video\/(\d*)\b/, "http://player.vimeo.com/video/\\1")
          .gsub(/(^.*soundcloud.*$)/, "http://w.soundcloud.com/player/?url=\\1")
      else
        nil
      end
    end

    def fx
      fx = self.instruction_list.keep_if {|i| i =~ /__FX_/}.join('_').gsub(/__FX_/, '').downcase
      fx == '' ? nil : fx
    end

    def update_with_evernote(note_content, note_data, cloud_note_tags)
      self.update_attributes!(
        :title => note_data.title,
        :body => note_data.content.gsub(/^.*[cap|alt|description]:.*$/i, ''),
        :lang => (ActionController::Base.helpers.strip_tags("#{ note_data.title } #{ note_content }"[0..Settings.notes.wtf_sample_length])).lang,
        :latitude => note_data.attributes.latitude,
        :longitude => note_data.attributes.longitude,
        :external_updated_at => Time.at(note_data.updated / 1000).to_datetime,
        :author => note_data.attributes.author,
        :last_edited_by => note_data.attributes.lastEditedBy,
        :source => note_data.attributes.source,
        :source_application => note_data.attributes.sourceApplication,
        :source_url => note_data.attributes.sourceURL,
        :tag_list => cloud_note_tags.grep(/^[^_]/),
        :instruction_list => cloud_note_tags.grep(/^_/)
      )
      Resource.update_all_with_evernote(self, note_data)
    end
end
