set :output, "#{ Whenever.path }/log/sync.log"

# REVIEW:
#  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
#  require 'rubygems'
#  every Settings.notes.synch_every_minutes.minutes do

every 1.minute do
  runner 'EvernoteNote.sync_all'
  runner 'Resource.sync_all_binaries'
  runner 'Book.sync_all'
  runner 'Link.sync_all'
end
