set :output, "#{ path }/log/daemons.log"

# REVIEW: get times from Settings
#  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
#  require 'rubygems'
#  every Settings.notes.synch_every_minutes.minutes do

every 1.minute do
  rake 'joegattnet:one_minute'
end

every '*/10 * * * *' do
  rake 'joegattnet:ten_minutes'
end

every '0 * * * *' do
  rake 'joegattnet:one_hour'
end

# Disabled until launch
# every 1.day, at: '5:00 am' do
#   rake '-s sitemap:refresh'
# end
