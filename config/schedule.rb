set :output, "#{ path }/log/daemons.log"

# REVIEW: get times from Settings
#  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
#  require 'rubygems'
#  every ENV['synch_every_minutes'].to_i.minutes do

every 3.minutes do
  rake 'joegattnet:three_minutes'
end

# every '*/10 * * * *' do
#   rake 'joegattnet:ten_minutes'
# end

every '0 * * * *' do
  rake 'joegattnet:one_hour'
end

every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end
