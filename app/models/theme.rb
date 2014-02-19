class Theme < ActiveRecord::Base

  has_many :channels

  scope :public, -> { where(public: true) }

  def self.hash_for_js
    #REVIEW: This can be more efficient
    themes_hash = Hash.new

    all.each do |t|
      themes_hash[t.slug] = { typekit_code: t.typekit_code, effects: t.effects, map_style: t.map_style }
    end
    themes_hash
  end
end
