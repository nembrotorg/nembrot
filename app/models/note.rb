# encoding: utf-8

class Note < ActiveRecord::Base

  include Syncable

  attr_writer :tag_list, :instruction_list

  has_many :evernote_notes, dependent: :destroy
  has_many :resources, dependent: :destroy

  has_many :related_notes_association, class_name: 'RelatedNote'
  has_many :related_notes, through: :related_notes_association, source: :related_note
  has_many :inverse_related_notes_association, class_name: 'RelatedNote', foreign_key: 'related_note_id'
  has_many :inverse_related_notes, through: :inverse_related_notes_association, source: :note

  has_and_belongs_to_many :books
  has_and_belongs_to_many :links

  acts_as_commontable

  acts_as_taggable_on :tags, :instructions

  has_paper_trail on: [:update],
                  only: [:title, :body],
                  if:  proc { |note| (note.external_updated_at - Note.find(note.id).external_updated_at) > Setting['advanced.version_gap_minutes'].to_i.minutes || note.get_real_distance > Setting['advanced.version_gap_distance'].to_i  },
                  unless: proc { |note| Setting['advanced.versions'] == false || note.has_instruction?('reset') || note.has_instruction?('unversion') },
                  meta: {
                    external_updated_at: proc { |note| Note.find(note.id).external_updated_at },
                    instruction_list: proc { |note| Note.find(note.id).instruction_list },
                    sequence: proc { |note| note.versions.length + 1 },  # To retrieve by version number
                    tag_list: proc { |note| Note.find(note.id).tag_list }, # Note.tag_list would store incoming tags
                    word_count: proc { |note| Note.find(note.id).word_count },
                    distance: proc { |note| Note.find(note.id).distance }
                  }

  default_scope { order(external_updated_at: :desc) }

  scope :blurbable, -> { where('word_count > ?', Setting['advanced.blurb_length'].to_i / Setting['advanced.average_word_length']) }
  scope :citations, -> { where(is_citation: true) }
  scope :features, -> { where.not(feature: nil) }
  scope :notes_and_features, -> { where(is_citation: false) }
  scope :listable, -> { where(listable: true, is_citation: false) }
  scope :publishable, -> { where(active: true, hide: false) }
  scope :interrelated, -> { where(id: RelatedNote.pluck(:note_id, :related_note_id)) }
  # scope :mappable, -> { where (is_mapped: true) }

  validates :title, :external_updated_at, presence: true
  validate :body_or_source_or_resource?, before: :update
  # validate :external_updated_is_latest?, before: :update

  before_save :update_metadata
  before_save :scan_note_for_references, if: :body_changed?
  after_save :scan_note_for_isbns, if: :body_changed?
  after_save :scan_note_for_urls, if: :body_changed? || :source_url_changed?

  paginates_per Setting['advanced.notes_index_per_page'].to_i

  # REVIEW: Store in columns like is_section?
  def self.mappable
    all.to_a.keep_if { |note| note.has_instruction?('map') && !note.inferred_latitude.nil? }
  end

  # REVIEW: Store in columns like is_section?
  def self.promotable
    promotions_home = Setting['style.promotions_home_columns'].to_i * Setting['style.promotions_home_rows'].to_i
    greater_promotions_number = [Setting['style.promotions_footer'].to_i, promotions_home].max
    (all.to_a.keep_if { |note| note.has_instruction?('promote') } + first(greater_promotions_number)).uniq
  end

  def self.sections
    where(is_section: true).pluck(:feature).uniq
  end

  def self.features
    where(is_feature: true, is_section: false).pluck(:feature).uniq
  end

  def has_instruction?(instruction, instructions = instruction_list)
    instruction_to_find = ["__#{ instruction.upcase }"]
    instruction_to_find.push(Setting["advanced.instructions_#{ instruction }"].split(/, ?| /)) unless Setting["advanced.instructions_#{ instruction }"].nil?
    instruction_to_find.flatten!

    all_relevant_instructions = Array(instructions)
    all_relevant_instructions.push(Setting['advanced.instructions_default'].split(/, ?| /))
    all_relevant_instructions.flatten!

    !(all_relevant_instructions & instruction_to_find).empty?
  end

  def headline
    return I18n.t('citations.show.title', id: id) if is_citation
    is_untitled? ? I18n.t('notes.show.title', id: id) : title
  end

  def type
    is_citation ? 'Citation' : 'Note'
  end

  def clean_body_with_instructions
    ActionController::Base.helpers.strip_tags(body.gsub(/<(b|h2|strong)>.*?<\/(b|h2|strong)>/, ''))
      .gsub(/\n\n*\r*/, "\n")
      .strip
  end

  def clean_body_with_parentheses
    clean_body_with_instructions
      .gsub(/\{\W*?quote\:/, '')
      .gsub(/\{[a-z]*?\:.*?\} ?/, '')
      .gsub(/\} ?/, '')
      .gsub(/\n|\r/, ' ')
      .gsub(/\s+/, ' ')
  end

  def clean_body
    clean_body_with_parentheses
      .gsub(/\([^\]]*?\)|\[[^\]]*?\]|\n|\r/, ' ')
      .gsub(/\s+/, ' ')
  end

  # REVIEW: If we named this embeddable_source_url? then we can't do
  #  self.embeddable_source_url? = version.embeddable_source_url? in diffed_version
  def is_embeddable_source_url
    (source_url && source_url =~ /youtube|vimeo|soundcloud/)
  end

  def fx
    instructions = Setting['advanced.instructions_default'].split(/, ?| /) + Array(instruction_list)
    fx = instructions.keep_if { |i| i =~ /__FX_/ }.each { |i| i.gsub!(/__FX_/, '').downcase! }
    fx.empty? ? nil : fx
  end

  def gmaps4rails_title
    headline
  end

  # If the note has no geo information then try to infer it from the image
  def inferred_latitude
    latitude.nil? ? (resources.first.nil? ? nil : resources.first.latitude) : latitude
  end

  def inferred_longitude
    longitude.nil? ? (resources.first.nil? ? nil : resources.first.longitude) : longitude
  end

  def inferred_altitude
    altitude.nil? ? (resources.first.nil? ? nil : resources.first.altitude) : altitude
  end

  def main_title
    has_instruction?('full_title') ? headline : headline.gsub(/\:.*$/, '')
  end

  def subtitle
    has_instruction?('full_title') ? nil : headline.scan(/\:\s*(.*)/).flatten.first
  end

  # def related_notes_resolved
  #   all_related_notes << related_notes
  #   all_related_notes.uniq.each do |r|
  #     all_related_notes << r.related_notes
  #   end
  #   all_related_notes
  # end

  def get_feature_name
    title_candidate = main_title
    title_candidate = main_title.split(' ').first if has_instruction?('feature_first')
    title_candidate = main_title.split(' ').last if has_instruction?('feature_last')
    title_candidate
  end

  def get_feature_id
    feature_id_candidate = title.scan(/^([0-9a-zA-Z]+)\. /).flatten.first
    feature_id_candidate = subtitle unless !feature_id_candidate.blank? || subtitle.blank? || has_instruction?('full_title')
    # sequence_feature_id = id.to_s if feature_id_candidate.blank?
    feature_id_candidate
  end

  def get_real_distance
    # Compare proposed version with saved version
    #  REVIEW: Are we confusing body with clean_body?
    #  body is used because it has a _was method
    return (title + body).length if body_was.blank?
    previous_title_and_body = title_was + body_was
    Levenshtein.distance(previous_title_and_body, title + body)
  end

  private

  def is_untitled?
    I18n.t('notes.untitled_synonyms').map(&:downcase).include?(title.downcase)
  end

  def external_updated_is_latest?
    return true if external_updated_at_was.blank?
    if external_updated_at <= external_updated_at_was
      errors.add(:external_updated_at, 'must be more recent than any other version')
      return false
    end
  end

  def update_lang(content = "#{ title } #{ clean_body }")
    lang_instruction = Array(instruction_list).select { |v| v =~ /__LANG_/ } .first
    if lang_instruction
     lang = lang_instruction.gsub(/__LANG_/, '').downcase
    else
      response = DetectLanguage.simple_detect(content[0..Constant.detect_language_sample_length.to_i])
      lang = Array(response.match(/^\w\w$/)).size == 1 ? response : nil
    end
    self.lang = lang
  end

  # REVIEW: Are the following two methods duplicated in Book?
  def scan_note_for_references
    self.books = Book.citable.to_a.keep_if { |book| body.include?(book.tag) }
    self.links = Link.publishable.to_a.keep_if { |link| body.include?(link.url) } if Setting['advanced.links_section'] == 'true'

    new_related_notes = Note.notes_and_features.where(id: body.scan(/\{[a-z ]*:? *\/?notes\/(\d+) *\}/).flatten)
    new_related_notes << Note.citations.where(id: body.scan(/\{[a-z ]*:? *\/?citations\/(\d+) *\}/).flatten)
    new_related_notes << Note.notes_and_features.where(feature: body.scan(/\{[a-z ]*:? *\/?([a-z0-9\-\_]*) *\}/).flatten, feature_id: nil)
    new_related_notes << Note.notes_and_features.where(feature: body.scan(/\{[a-z ]*:? *\/?([a-z0-9\-\_]*)\//).flatten, feature_id: body.scan(/\{[a-z ]*:? *\/?[a-z0-9\-\_]*\/([a-z0-9\-\_]*) *\}/).flatten)

    self.related_notes = new_related_notes.flatten.uniq
  end

  def scan_note_for_isbns
    # REVIEW: try checking for setting as an unless: after before_save
    Book.grab_isbns(body) unless Setting['advanced.books_section'] == 'false' || body.blank?
  end

  def scan_note_for_urls
    # REVIEW: try checking for setting as an unless: after before_save
    Link.grab_urls(body, source_url) unless Setting['advanced.links_section'] == 'false' || clean_body.blank? && source_url.blank?
  end

  def body_or_source_or_resource?
    if body.blank? && !is_embeddable_source_url && resources.blank?
      errors.add(:note, 'Note needs one of body, source or resource.')
    end
  end

  def update_metadata
    discard_versions?
    update_is_hidable?
    update_is_citation?
    update_is_listable?
    update_is_feature?
    update_is_section?
    keep_old_date?
    update_lang
    update_feature
    update_feature_id
    update_word_count
    update_distance
  end

  def discard_versions?
    if has_instruction?('reset') && !versions.empty?
      self.external_updated_at = versions.first.reify.external_updated_at if Setting['advanced.always_reset_on_create']
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

  def update_is_feature?
    self.is_feature = has_instruction?('feature')
  end

  def update_is_section?
    self.is_section = has_instruction?('section')
  end

  def update_word_count
    self.word_count = clean_body.split.size
  end

  def update_distance
    # Here we can't use body_was and title_was because we want to compart to the last _saved_ version
    previous_title_and_body = ''
    unless versions.empty?
      previous_version = versions.last.reify
      previous_title_and_body = previous_version.title + previous_version.body
    end
    self.distance = Levenshtein.distance(previous_title_and_body, title + body)
  end

  def update_feature
    self.feature = has_instruction?('feature') ? get_feature_name.parameterize : nil
  end

  def update_feature_id
    feature_id_candidate = get_feature_id
    self.feature_id = get_feature_id.parameterize unless feature_id_candidate.nil?
  end
end
