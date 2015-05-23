# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
#Nembrot::Application.initialize!

# Enforcing UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

Rails.application.initialize!
