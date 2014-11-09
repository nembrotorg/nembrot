Geocoder.configure(
  :cache => Rails.cache,
  :ip_lookup => :maxmind,
  :timeout => 15,
  :maxmind => { :service => :country }
)
