# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Nembrot::Application

# To avoid an error on Travis CI:
#  https://travis-ci.org/joegattnet/joegattnet_v3/builds/8420897
require 'sass'
