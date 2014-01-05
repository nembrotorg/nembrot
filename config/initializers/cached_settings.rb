module RailsSettings
  class CachedSettings < Settings
    after_update :rewrite_cache
    after_create :rewrite_cache

    def rewrite_cache
      Rails.cache.write("#{ self.class.cache_name }:#{ self.var }", self.value)
    end

    after_destroy { |record| Rails.cache.delete("#{ self.class.cache_name }:#{ record.var }") }

    def self.[](var_name)
      cache_key = "#{ cache_name }:#{ var_name }"
      obj = Rails.cache.fetch(cache_key) {
        super(var_name)
      }
      obj == nil ? @@defaults[var_name.to_s] : obj
    end

    def self.save_default(key, value)
      self.send("#{ key }=", value) if self.send(key) == nil
    end

    def self.cache_name
      # Rather than getting the app name, get the root folder name so that
      #  discrete instances of an application do not collide
      #  REVIEW: consider using namespace - why isn't it being used?
      "#{ Rails.root.to_s.parameterize }_#{ Rails.env }_settings"
    end
  end
end
