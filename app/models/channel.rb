class Channel < ActiveRecord::Base

  belongs_to :user
  # serialize :notebooks

  validates :name, :notebooks, :theme, presence: true
  validates :name, uniqueness: true

  # before_validation :slug, if: :name_changed?, unless: :slug_changed?

  extend FriendlyId
  friendly_id :name, use: :slugged

  def to_param
    slug
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
