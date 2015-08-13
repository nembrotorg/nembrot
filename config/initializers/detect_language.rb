DetectLanguage.configure do |config|
  config.api_key = Figaro.env.detect_language_key
end
