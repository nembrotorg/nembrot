source 'https://rubygems.org'

gem 'rails',          '3.2.5'

gem 'json'

gem 'acts-as-taggable-on', '~> 2.2.2'

gem 'haml'
gem 'haml-rails'

gem 'jquery-rails'

gem 'html5-rails'

gem 'unicorn'

group :development do
  gem 'sqlite3',      '1.3.5'
  gem 'rspec-rails',  '2.11.0'
  gem 'factory_girl_rails'
  gem 'guard-rspec',  '0.5.5'
  gem 'capistrano'
end

group :assets do
  gem 'sass-rails',   '3.2.4'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier',     '1.2.3'
  gem 'compass-rails'
  gem 'compass-h5bp'
end

# Test set-up from http://ruby.railstutorial.org/chapters/static-pages#sec:guard
# And http://everydayrails.com/2012/03/12/testing-series-rspec-setup.html
group :test do
  gem 'sqlite3',      '1.3.5'
  gem 'faker'
  gem 'rspec-rails',  '2.11.0'
  gem 'factory_girl_rails'
  gem 'capybara',     '1.1.2'
  gem 'guard-spork',  '0.3.2'
  gem 'spork',        '0.9.0'
  gem 'launchy'
  
  # System-dependent gems
  # Linux
  # gem 'rb-inotify', '0.8.8'
  # gem 'libnotify',  '0.5.9'

  # Mac OSX
  gem 'rb-fsevent',   '0.4.3.1', :require => false
  gem 'growl',        '1.0.3'

  # Windows
  # gem 'rb-fchange', '0.0.5'
  # gem 'rb-notifu',  '0.0.4'
  # gem 'win32console', '1.3.0'
end

group :staging, :production do
  gem 'therubyracer',   '>= 0.9.2'
  gem 'pg',           '0.12.2'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use debugger
# gem 'ruby-debug'

gem 'devise'

gem 'rails_admin'
