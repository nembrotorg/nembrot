class Channel < ActiveRecord::Base

  belongs_to :user
  belongs_to :theme

  validates :name, :notebooks, presence: true
  validates :name, uniqueness: true

  # before_validation :slug, if: :name_changed?, unless: :slug_changed?

  scope :owned_by_nembrot, -> { joins(:theme).where.not('themes.public = ?', true) }
  scope :not_owned_by_nembrot, -> { joins(:theme).where('themes.public = ?', true) }

  extend FriendlyId
  friendly_id :name, use: :slugged

  def owned_by_nembrot?
    theme.public != true
  end

  def to_param
    slug
  end

  def home_note
    Note.channelled(self).publishable.listable.blurbable.homeable.first
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
