class Channel < ActiveRecord::Base

  belongs_to :user
  belongs_to :theme

  validates :name, :notebooks, presence: true
  validates :name, uniqueness: true

  # before_validation :slug, if: :name_changed?, unless: :slug_changed?

  scope :owned_by_nembrot, -> { joins(:user).where('channels.name = ?', 'default') }
  scope :not_owned_by_nembrot, -> { joins(:user).where.not('channels.name = ?', 'default') }

  extend FriendlyId
  friendly_id :name, use: :slugged

  def owned_by_nembrot?
    (name == 'default')
  end

  def to_param
    slug
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
