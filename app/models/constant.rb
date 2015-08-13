class Constant < Settingslogic
  source "#{ Rails.root }/config/constants.yml"
  namespace Rails.env

  Dir.glob("#{ Rails.root }/config/*.constants.yml") do |extra_settings_file|
    instance.deep_merge!(Constant.new(extra_settings_file))
  end

  load!
end
