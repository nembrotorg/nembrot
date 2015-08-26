set :output, "#{ path }/log/daemons.log"

# FIXME: We should be able to do this with stage
if path == '/home/deployer/apps/joegattnet_v3'

  every 60.minutes do
    rake '-s joegattnet:one_hour'
  end

  every 1.day, at: '5:00 am' do
    rake '-s sitemap:refresh'
  end
end
