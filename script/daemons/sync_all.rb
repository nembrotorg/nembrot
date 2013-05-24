#require ENV["RAILS_ENV_PATH"]
require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))
require 'rubygems'

loop do
  puts "Fetching at #{ Time.now.to_s(:time) }..."
  EvernoteNote.sync_all
  Resource.sync_all_binaries
  Book.sync_all
  sleep Settings.evernote.daemon_frequency
end
