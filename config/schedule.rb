set :output, "#{ path }/log/daemons.log"

if ENV['RAILS_ENV'] == 'production'

  every 3.minutes do
    rake 'joegattnet:three_minutes'
  end

  every '0 * * * *' do
    rake 'joegattnet:one_hour'
  end

end

every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end
