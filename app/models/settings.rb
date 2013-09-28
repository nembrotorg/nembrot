class Settings < Settingslogic
  source "#{ Rails.root }/config/settings.yml"
  namespace Rails.env

  Dir.glob("#{ Rails.root }/config/*.settings.yml") do |extra_settings_file|
    instance.deep_merge!(Settings.new(extra_settings_file))
  end
end
