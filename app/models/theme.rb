class Theme < ActiveRecord::Base

  has_many :channels

  # REVIEW: These would make theme management easier
  # has_one  :typekit_code
  # has_many :effects, :css_modules

  default_scope { order(:name) }
  scope :public, -> { where(public: true) }

  before_validation :update_slug

  def self.hash_for_js
    #REVIEW: This can be more efficient
    themes_hash = Hash.new

    all.each do |t|
      themes_hash[t.slug] = { name: t.name, typekit_code: t.typekit_code, effects: t.effects, map_style: t.map_style, css: t.css }
    end
    themes_hash
  end

  def fx
    effects.split(/ |\, ?/)
  end

  private

  def update_slug
    self.slug = name.parameterize
  end
end
