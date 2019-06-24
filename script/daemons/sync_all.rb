# require ENV["RAILS_ENV_PATH"]
require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))
require 'rubygems'

loop do
  EvernoteNote.sync_all
  Resource.sync_all_binaries
  Book.sync_all
  Link.sync_all
  sleep NB.daemon_frequency.to_i
end
