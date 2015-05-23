class Secret < Settingslogic
  secret_file = "#{ Rails.root }/config/secret.yml"
  secret_sample_file = "#{ Rails.root }/config/secret.sample.yml"
  source_file = (File.exist? secret_file) ? secret_file : secret_sample_file

  source source_file
  namespace Rails.env
  load!
end
