# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Nembrot::Application.initialize!

# Indent all HTML output
Haml::Template.options[:ugly] = false
Haml::Template.options[:attr_wrapper] = "\""
Haml::Template.options[:format] = :html5

# Enforcing UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Set default format for Differ
Differ.format = Differ::Format::CLEAN_HTML

Nembrot::Application.configure do

  #Mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => Settings.mailer.address,
    :port                 => Settings.mailer.port,
    :domain               => Settings.mailer.domain,
    :user_name            => Secret.mailer.user_name,
    :password             => Secret.mailer.password,
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }
  config.action_mailer.default_url_options = { 
    :host => Settings.host
  }

end
