# See https://github.com/javan/whenever/pull/332
job_type :runner, "cd :path && bin/rails runner -e :environment ':task' :output"

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'rubygems'

set :output, "#{ Whenever.path }/log/sync.log"

every Settings.notes.synch_every_minutes.minutes do
  runner 'EvernoteNote.sync_all'
  runner 'Resource.sync_all_binaries'
  runner 'Book.sync_all'
  runner 'Link.sync_all'
end
