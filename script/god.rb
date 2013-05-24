#!/usr/bin/env ruby

# Load the rails application
require File.expand_path('../../config/application', __FILE__)

God.watch do |w|
  w.name = "sync_all"
  w.start = "ruby #{ File.join(Rails.root, 'script', 'daemons', 'sync_all.rb') }"
  w.keepalive
  w.log = "#{ File.join(Rails.root, 'log', 'daemons.log') }"
  #  w.keepalive(:memory_max => 150.megabytes,
  #              :cpu_max => 50.percent)
end
