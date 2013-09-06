# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'rubygems'

set :output, "#{ Whenever.path }/log/sync.log"

every Settings.notes.synch_every_minutes.minutes do
  runner 'EvernoteNote.sync_all'
  runner 'Resource.sync_all_binaries'
  runner 'Book.sync_all'
  runner 'Link.sync_all'
end
