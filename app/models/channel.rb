class Channel < ActiveRecord::Base

  belongs_to :user
  # serialize :notebooks

  validates :name, :notebooks, :theme, presence: true
  validates :name, uniqueness: true

  # before_validation :slug, if: :name_changed?, unless: :slug_changed?

  scope :owned_by_nembrot, -> { joins(:user).where(users: { nickname: Secret.auth.evernote.username }) }
  scope :not_owned_by_nembrot, -> { joins(:user).where.not(users: { nickname: Secret.auth.evernote.username }) }

  extend FriendlyId
  friendly_id :name, use: :slugged

  def owned_by_nembrot?
    (user.nickname == Secret.auth.evernote.username)
  end

  def to_param
    slug
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
