# encoding: utf-8

class Note < ActiveRecord::Base

  include ApplicationHelper

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang, :author,
                  :last_edited_by, :source, :source_application, :source_url, :sources, :tag_list, :instruction_list,
                  :hide, :active

  attr_writer :tag_list, :instruction_list

  has_many :cloud_notes, dependent: :destroy
  has_many :resources, dependent: :destroy
  has_and_belongs_to_many :sources

  acts_as_taggable_on :tags, :instructions

  has_paper_trail on: [:update],
                  meta: {
                    sequence:  proc { |note| note.versions.length + 1 },  # To retrieve by version number
                    tag_list:  proc { |note| Note.find(note.id).tag_list }, # Note.tag_list would store incoming tag list
                    instruction_list:  proc { |note| Note.find(note.id).instruction_list }
                  }

  scope :publishable, where('active = ? AND hide = ?', true, false)
  default_scope order: 'external_updated_at DESC'

  validates :title, :external_updated_at, presence: true
  validate :body_or_source_or_resource, before: :update

  # FIXME: Doesn't work with :body_changed?
  before_validation :scan_note_for_references # , :if => :body_changed?
  before_validation :scan_note_for_isbns      # , :if => :body_changed?

  def body_or_source_or_resource
    if body.blank? && embeddable_source_url.blank? && resources.blank?
      errors.add(:note, 'Note needs one of body, source or resource.')
    end
  end

  # Being activated on create and throws error
  # validate :external_updated_at_must_be_latest, :before => :update

  def headline
    I18n.t('notes.untitled_synonyms').include?(title) ? I18n.t('notes.short', id: id) : title
  end

  def blurb
    # If the title is derived from the body, we do not include it in the blurb
    if body.index(title) == 0
      "<h2>#{ headline }</h2> #{ body[headline.length .. Settings.notes.blurb_length * 2] }"
    else
      "<h2>#{ headline }</h2>: #{ body }"
    end
  end

  def embeddable_source_url
    if source_url && source_url =~ /youtube|vimeo|soundcloud/
      source_url
        .gsub(/^.*youtube.*v=(.*)\b/, 'http://www.youtube.com/embed/\\1?rel=0')
        .gsub(%r(^.*vimeo.*/video/(\d*)\b), 'http://player.vimeo.com/video/\\1')
        .gsub(/(^.*soundcloud.*$)/, 'http://w.soundcloud.com/player/?url=\\1')
    else
      nil
    end
  end

  def instructed_to?(instruction, instructions = instruction_list)
    (Settings.notes.instructions + instructions).include? "__#{ instruction.upcase }"
  end

  def fx
    fx = (Settings.notes.instructions + Array(instruction_list)).keep_if { |i| i =~ /__FX_/ }
                                                         .join('_')
                                                         .gsub(/__FX_/, '')
                                                         .downcase
    fx == '' ? nil : fx
  end

  # private
    # def external_updated_at_must_be_latest
    #     if !external_updated_at_was.blank? && external_updated_at <= external_updated_at_was
    #       errors.add( :external_updated_at, 'must be more recent than any other version' )
    #       return false
    #     end
    # end

  def update_with_evernote_data(note_data, cloud_note_tags)
    update_attributes!(
      title: note_data.title,
      body: sanitize_for_db(note_data.content),
      lang: lang_from_cloud("#{ note_data.title } #{ note_data.content }"),
      latitude: note_data.attributes.latitude,
      longitude: note_data.attributes.longitude,
      external_updated_at: calculate_updated_at(note_data, cloud_note_tags),
      author: note_data.attributes.author,
      last_edited_by: note_data.attributes.lastEditedBy,
      source: note_data.attributes.source,
      source_application: note_data.attributes.sourceApplication,
      source_url: note_data.attributes.sourceURL,
      tag_list: cloud_note_tags.grep(/^[^_]/),
      instruction_list: cloud_note_tags.grep(/^_/),
      hide: instructed_to?('hide'),
      active: true
    )
    update_resources_with_evernote_data(note_data)
  end

  def sanitize_for_db(content)
    content.gsub(/^(:?cap|alt|description|credit):.*$/i, '')
           .gsub(/<b>|<h\d>/, '<strong>')
           .gsub(/<\/b>|<h\d>/, '</strong>')
           .gsub(/\&nbsp\;/, ' ')
           .gsub(/[\n]+/, '\n')
           .strip
    ActionController::Base.helpers.sanitize(content, tags: Settings.notes.allowed_html_tags,
                                            attributes: Settings.notes.allowed_html_attributes)
  end

  def lang_from_cloud(content)
    (ActionController::Base.helpers.strip_tags(content[0..Settings.notes.wtf_sample_length])).lang
  end

  def calculate_updated_at(note_data, cloud_note_tags)
    use_date = note_data.updated
    # REVIEW: this method does two things
    # Also, a version is still created after saving.
    unless (Settings.evernote.instructions.reset & cloud_note_tags).empty?
      use_date = note_data.created
      versions.destroy_all
    end

    use_date = note_data.created if external_updated_at.blank? && Settings.evernote.reset

    Time.at(use_date / 1000).to_datetime
  end

  def scan_note_for_references
    # REVIEW: Should this be in Book?
    self.sources = Book.citable.keep_if { |book| self.body.include?(book.tag) }
  end

  def scan_note_for_isbns
    Book.grab_isbns(body) unless body.blank?
  end

  # REVIEW: When a note contains both images and downloads, the alt/cap is disrupted
  def update_resources_with_evernote_data(cloud_note_data)
    cloud_resources = cloud_note_data.resources
    captions = cloud_note_data.content.scan(/^\s*cap:\s*(.*?)\s*$/i)
    descriptions = cloud_note_data.content.scan(/^\s*(?:alt|description):\s*(.*?)\s*$/i)
    credits = cloud_note_data.content.scan(/^\s*credit:\s*(.*?)\s*$/i)

    # First we remove all resources (to make sure deleted resources disappear -
    #  but we don't want to delete binaries so we use #delete rather than #destroy)
    resources.delete_all

    if cloud_resources
      cloud_resources.each_with_index do |cloud_resource, index|

        resource = resources.where(cloud_resource_identifier: cloud_resource.guid).first_or_create

        caption = captions[index] ? captions[index][0] : ''
        description = descriptions[index] ? descriptions[index][0] : ''
        credit = credits[index] ? credits[index][0] : ''

        resource.update_with_evernote_data(cloud_resource, caption, description, credit)
      end
    end
  end
end
