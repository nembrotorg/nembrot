set :output, "#{ path }/log/sync.log"

# REVIEW:
#  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
#  require 'rubygems'
#  every Settings.notes.synch_every_minutes.minutes do

every 1.minute do
  rake 'sync:all'
end
