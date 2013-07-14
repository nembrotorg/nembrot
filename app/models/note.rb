# encoding: utf-8

class Note < ActiveRecord::Base

  include Syncable

  attr_accessible :title, :body, :external_updated_at, :resources, :latitude, :longitude, :lang, :author,
                  :last_edited_by, :source, :source_application, :source_url, :sources, :tag_list, :instruction_list,
                  :hide, :active, :is_citation, :listable

  attr_writer :tag_list, :instruction_list

  has_many :evernote_notes, dependent: :destroy
  has_many :resources, dependent: :destroy
  has_and_belongs_to_many :books

  acts_as_taggable_on :tags, :instructions

  has_paper_trail on: [:update],
                  only: [:title, :body],
                  unless: proc { |note| note.has_instruction?('reset') || note.has_instruction?('unversion') },
                  meta: {
                    word_count:  proc { |note| Note.find(note.id).word_count },
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
  # validate :external_updated_is_latest?, before: :update

  before_save :update_metadata
  before_save :scan_note_for_references, if: :body_changed?
  after_save :scan_note_for_isbns, if: :body_changed?

  def has_instruction?(instruction, instructions = instruction_list)
    instruction_to_find = ["__#{ instruction.upcase }"]
    instruction_to_find.push(Settings.notes['instructions'][instruction]) unless Settings.notes['instructions'][instruction].nil?
    instruction_to_find.flatten!

    places_to_search = Array(instructions)
    places_to_search.push(Settings.notes.instructions.default)
    places_to_search.flatten!

    !(places_to_search & instruction_to_find).empty?
  end

  def headline
    return I18n.t('citations.show.title', id: id) if is_citation
    I18n.t('notes.untitled_synonyms').include?(title) ? I18n.t('notes.show.title', id: id) : title
  end

  def type
    is_citation ? 'Citation' : 'Note'
  end

  def clean_body_with_instructions
    ActionController::Base.helpers.strip_tags(body).gsub(/\n\n*\r*/, "\n").strip
  end

  def clean_body
    clean_body_with_instructions
      .gsub(/^\W*?quote\:/, '')
      .gsub(/^\w*?\:.*$/, '')
      .gsub(/\([^\]]*?\)|\[[^\]]*?\]|\n|\r/, ' ')
      .gsub(/\s+/, ' ')
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

  private

  def external_updated_is_latest?
    return true if external_updated_at_was.blank?
    if external_updated_at <= external_updated_at_was
      errors.add( :external_updated_at, 'must be more recent than any other version' )
      return false
    end
  end

  def update_lang(content = "#{ title } #{ clean_body }")
    lang_instruction = Array(instruction_list).select { |v| v =~ /__LANG_/ } .first
    if lang_instruction
     lang = lang_instruction.gsub(/__LANG_/, '').downcase
    else
      response = DetectLanguage.simple_detect(content[0..Settings.notes.detect_language_sample_length])
      lang = Array(response.match(/^\w\w$/)).size == 1 ? response : nil
    end
    self.lang = lang
  end

  def scan_note_for_references
    self.books = Book.citable.keep_if { |book| body.include?(book.tag) }
  end

  def scan_note_for_isbns
    Book.grab_isbns(body) unless body.blank?
  end

  def body_or_source_or_resource
    if body.blank? && embeddable_source_url.blank? && resources.blank?
      errors.add(:note, 'Note needs one of body, source or resource.')
    end
  end

  def update_metadata
    discard_versions?
    update_is_hidable?
    update_is_citation?
    update_is_listable?
    keep_old_date?
    update_lang
    update_word_count
  end

  def discard_versions?
    if has_instruction?('reset') && !versions.empty?
      self.external_updated_at = versions.first.reify.external_updated_at if Settings.evernote.always_reset_on_create
      versions.destroy_all
    end
  end

  def update_is_citation?
    self.is_citation = has_instruction?('citation') || looks_like_a_citation?(clean_body)
  end

  def looks_like_a_citation?(content = clean_body)
    content.scan(/\A\W*quote\:(.*?)\n?\-\- *?(.*?[\d]{4}.*)\W*\Z/).size == 1 # OPTIMIZE: Replace 'quote': by i18n
  end

  def update_is_listable?
    self.listable = !has_instruction?('unlist')
  end

  def keep_old_date?
    # If this is a minor update (i.e. we're not creating a new version), we keep the old date.
    self.external_updated_at = external_updated_at_was unless title_changed? || body_changed?
  end

  def update_is_hidable?
    self.hide = has_instruction?('hide')
  end

  def update_word_count
    self.word_count = clean_body.split.size
  end

end
