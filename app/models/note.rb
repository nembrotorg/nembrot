# encoding: utf-8

class Note < ActiveRecord::Base

  include SyncHelper

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang, :author,
                  :last_edited_by, :source, :source_application, :source_url, :sources, :tag_list, :instruction_list,
                  :hide, :active, :is_citation, :listable

  attr_writer :tag_list, :instruction_list

  has_many :evernote_notes, dependent: :destroy
  has_many :resources, dependent: :destroy
  has_and_belongs_to_many :books

  acts_as_taggable_on :tags, :instructions

  has_paper_trail on: [:update],
                  unless: proc { |note| note.has_instruction?('reset') },
                  meta: {
                    sequence:  proc { |note| note.versions.length + 1 },  # To retrieve by version number
                    tag_list:  proc { |note| Note.find(note.id).tag_list }, # Note.tag_list would store incoming tags
                    instruction_list:  proc { |note| Note.find(note.id).instruction_list }
                  }

  default_scope order: 'external_updated_at DESC'
  scope :publishable, where(active: true, hide: false)
  scope :listable, where(listable: true, is_citation: false)
  scope :citations, where(is_citation: true)

  validates :title, :external_updated_at, presence: true
  validate :body_or_source_or_resource, before: :update
  # Being activated on create and throws error
  # validate :external_updated_at_must_be_latest, :before => :update

  before_save :discard_versions? #, :if => :instruction_list_changed?
  before_save :scan_note_for_references, :if => :body_changed?
  after_save :scan_note_for_isbns, :if => :body_changed?

  def body_or_source_or_resource
    if body.blank? && embeddable_source_url.blank? && resources.blank?
      errors.add(:note, 'Note needs one of body, source or resource.')
    end
  end

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

  def citation_blurb
    citation_blurb = body.gsub(/^.*quote:/, '')
    attribution = citation_blurb.scan(/--.*?$/m).first
    "#{ citation_blurb[0 .. Settings.notes.blurb_length] }#{ attribution }"
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

  def fx
    instructions = Settings.notes.instructions.default + Array(instruction_list)
    fx = instructions.keep_if { |i| i =~ /__FX_/ } .join('_').gsub(/__FX_/, '').downcase
    fx.empty? ? nil : fx
  end

  # private
    # def external_updated_at_must_be_latest
    #     if !external_updated_at_was.blank? && external_updated_at <= external_updated_at_was
    #       errors.add( :external_updated_at, 'must be more recent than any other version' )
    #       return false
    #     end
    # end

  def scan_note_for_references
    # REVIEW: Should this be in Book?
    self.books = Book.citable.keep_if { |book| body.include?(book.tag) }
  end

  def scan_note_for_isbns
    Book.grab_isbns(body) unless body.blank?
  end

  def discard_versions?
    versions.destroy_all if has_instruction?('reset')
  end

  # REVIEW: When a note contains both images and downloads, the alt/cap is disrupted
  def update_resources_with_evernote_data(cloud_note_data)
    cloud_resources = cloud_note_data.resources

    # Since we're reading straight from Evernote data we use <div> and </div> rather than ^ and $ as line delimiters.
    #  If we end up using a sanitized version of the body for other uses (e.g. wordcount), then we can use that.
    captions = cloud_note_data.content.scan(/<div>\s*cap:\s*(.*?)\s*<\/div>/i)
    descriptions = cloud_note_data.content.scan(/<div>\s*(?:alt|description):\s*(.*?)\s*<\/div>/i)
    credits = cloud_note_data.content.scan(/<div>\s*credit:\s*(.*?)\s*<\/div>/i)

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
