DetectLanguage.configure do |config|
  config.api_key = Secret.auth.detect_language.key
end
