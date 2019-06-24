set :output, "#{ path }/log/daemons.log"
set :environment, ENV['RAILS_ENV']
env :PATH, ENV['PATH']

if environment == 'production'
  every 1.hour do
    rake 'joegattnet:one_hour'
  end

  every 1.day, at: '5:00 am' do
    rake '-s sitemap:refresh'
  end
end
