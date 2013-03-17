class Note < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang, :author, 
  :last_edited_by, :source, :source_application, :source_url, :tag_list, :instruction_list, :hide, :active

  attr_writer :tag_list, :instruction_list

  has_many :cloud_notes, :dependent => :destroy
  has_many :resources, :dependent => :destroy

  acts_as_taggable_on :tags, :instructions

  has_paper_trail :on => [:update],
                  :meta => {
                    # Adding a sequence enables us to retrieve by version number
                    :sequence  => Proc.new { |note| note.versions.length + 1 },
                    # Simply storing note.tag_list would store incoming tag list
                    :tags  => Proc.new { |note| Note.find(note.id).tags },
                    :instructions  => Proc.new { |note| Note.find(note.id).instructions }
                  }

  scope :publishable, where("active = ? AND hide = ?", true, false)
  default_scope :order => 'external_updated_at DESC'

  # TODO: :body is allowed to be blank - but should make sure that at least an image or embedded media is present.
  validates :title, :external_updated_at, :presence => true

  # Being activated on create and throws error
  # validate :external_updated_at_must_be_latest, :before => :update

  # before_delete: delete_binaries

  def headline
    (I18n.t('notes.untitled_synonyms').include? self.title) ? "Note #{ id }" : self.title
  end

  def blurb
    # If the title is derived from the body, we do not include it in the blurb
    if self.body.index(self.title) == 0
      "<h2>#{ self.headline }</h2> #{ self.body[self.headline.length .. Settings.notes.blurb_length * 2] }"
    else
      "<h2>#{ self.headline }</h2>: #{ self.body }"
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

  def instructed_to?(instruction, instructions = instruction_list)
    (Settings.notes.instructions + instructions).include? ("__#{ instruction.upcase }")
  end

  def fx
    fx = (Settings.notes.instructions + instruction_list).keep_if {|i| i =~ /__FX_/}.join('_').gsub(/__FX_/, '').downcase
    fx == '' ? nil : fx
  end

  def diffed_version(sequence)
    if sequence == 1
      # If retrieveing the first version, we create an empty version object and an empty array
      #  to enable to diff against them
      version = self.versions.first.reify
      previous = OpenStruct.new({
        :title => '',
        :body => '',
        :tags => Array.new
      })
    elsif sequence == self.versions.size + 1
      # If we're requesting the latest (current) version, we select the current note as the
      #  version, and the last stored version as previous
      version = self
      previous = self.versions.last.reify
    else
      version = self.versions.find_by_sequence(sequence).reify
      previous = version.previous_version
    end

    # We calculate the difference between current and previous tag lists,
    #  and set diff_status accordingly so we can mark up list in view
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

  def update_with_evernote_data(note_data, cloud_note_tags)
    update_attributes!(
      :title => note_data.title,
      :body => sanitize_for_db(note_data),
      :lang => lang_from_cloud(note_data),
      :latitude => note_data.attributes.latitude,
      :longitude => note_data.attributes.longitude,
      :external_updated_at => calculate_updated_at(note_data, cloud_note_tags),
      :author => note_data.attributes.author,
      :last_edited_by => note_data.attributes.lastEditedBy,
      :source => note_data.attributes.source,
      :source_application => note_data.attributes.sourceApplication,
      :source_url => note_data.attributes.sourceURL,
      :tag_list => cloud_note_tags.grep(/^[^_]/),
      :instruction_list => cloud_note_tags.grep(/^_/),
      :hide => instructed_to?('hide'),
      :active => true
    )
    update_resources_with_evernote_data(note_data)
  end

  def sanitize_for_db(note_data)
    note_data.content.gsub(/^(:?cap|alt|description|credit):.*$/i, '').gsub(/[\n]+/, "\n").strip
  end

  def lang_from_cloud(note_data)
    (ActionController::Base.helpers.strip_tags("#{ note_data.title } #{ note_data.content }"[0..Settings.notes.wtf_sample_length])).lang    
  end

  def calculate_updated_at(note_data, cloud_note_tags)
    use_date = note_data.updated

    if !(Settings.evernote.instructions.reset & cloud_note_tags).empty?
      use_date = note_data.created
      versions.destroy_all
    end

    if external_updated_at.nil? && Settings.evernote.reset
      use_date = note_data.created
    end

    Time.at(use_date / 1000).to_datetime
  end

  # REVIEW: When a note contains both images and downloads, the alt/cap is disrupted
  def update_resources_with_evernote_data(cloud_note_data)
    cloud_resources = cloud_note_data.resources
    captions = cloud_note_data.content.scan(/^\s*cap:\s*(.*?)\s*$/i)
    descriptions = cloud_note_data.content.scan(/^\s*(?:alt|description):\s*(.*?)\s*$/i)
    credits = cloud_note_data.content.scan(/^\s*credit:\s*(.*?)\s*$/i)

    # First we remove all resources (to make sure deleted resources disappear - 
    #  but we don't want to delete binaries - binaries should only be deleted when the note itself is deleted)
    resources.destroy_all 

    if cloud_resources
      cloud_resources.each_with_index do |cloud_resource, index|

        resource = resources.where(:cloud_resource_identifier => cloud_resource.guid).first_or_create

        caption = captions[index] ? captions[index][0] : ''
        description = descriptions[index] ? descriptions[index][0] : ''
        credit = credits[index] ? credits[index][0] : ''

        resource.update_with_evernote_data(cloud_resource, caption, description, credit)
      end
    end
  end

  #def delete_binaries
  #  self.resources.each do |resource|
  #    File.delete resource.raw_location
  #    # self.local_file_name
  #  end
  #end
end
