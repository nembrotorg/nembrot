class Channel < ActiveRecord::Base

  belongs_to :user, autosave: true, validate: false
  belongs_to :theme

  validates :name, :notebooks, presence: true
  validates :name, uniqueness: true

  # validate :notebook_in_plan?, before: :update
  validate :theme_in_plan?, before: :update

  # before_validation :slug, if: :name_changed?, unless: :slug_changed?

  default_scope { order('active DESC, name') }
  scope :active, -> { where(active: true) }
  scope :has_notes, -> { active.where(has_notes: true) }
  scope :owned_by_nembrot, -> { active.joins(:theme).where.not('themes.public = ?', true) }
  scope :not_owned_by_nembrot, -> { active.joins(:theme).where('themes.public = ?', true) }
  scope :premium_themed, -> { joins(:theme).where.not('themes.premium = ?', true).readonly(false) }
  scope :sitemappable, -> { has_notes.where(index_on_google: true) }
  scope :promotable, -> { has_notes.where(promote: true) }
  scope :promoted, -> { has_notes.not_owned_by_nembrot.where(promote: true, promoted: true) }

  delegate :newsletter, :newsletter=, to: :user

  extend FriendlyId
  friendly_id :name, use: :slugged

  def owned_by_nembrot?
    theme.public != true
  end

  def to_param
    slug
  end

  def home_note
    Note.includes(:resources).channelled(self).publishable.homeable.first
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def self.channels_that_use_this_note(note)
    # REVIEW: Should this be a scope?
    where(notebooks: note.evernote_notes.first.cloud_notebook_identifier, locale_auto: true)
  end

  def self.update_locales(note)
    # Update a channel's locale according to the language it most uses
    self.channels_that_use_this_note(note).each do |channel|
      locale =  Note.unscoped
          .channelled(channel)
          .publishable
          .select("COUNT(*) AS count, lang")
          .group("lang")
          .order("count DESC")
          .first
          .lang
      channel.update_attribute(:locale, locale)
    end
  end

  private

  def theme_in_plan?
    theme.premium == false || user.plan.premium_themes?
  end
end
