class Settings < Settingslogic
  source "#{Rails.root}/config/nembrot.yml"
  namespace Rails.env
end
