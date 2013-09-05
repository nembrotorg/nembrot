class Secret < Settingslogic
  source "#{Rails.root}/config/secret.yml"
  namespace Rails.env
end
