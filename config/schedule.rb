set :output, "#{ path }/log/daemons.log"

if stage == 'production'
  every 1.hour do
    rake 'joegattnet:one_hour'
  end

  every 1.day, at: '5:00 am' do
    rake '-s sitemap:refresh'
  end
end
