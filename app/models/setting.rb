class Setting < RailsSettings::CachedSettings
  def self.reset(namespace)
    Constant[namespace].map do |key, value|
      Setting["#{ namespace }.#{ key }"] = value
    end
  end
end
