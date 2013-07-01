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
