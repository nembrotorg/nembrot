source 'https://rubygems.org'

gem 'rails',          '3.2.8'

gem 'json'

gem 'unicorn'

gem 'friendly_id',          '~> 4.0.1'
gem 'acts-as-taggable-on',  '~> 2.3.3'
gem 'paper_trail'

gem 'differ'

gem 'haml'
gem 'haml-rails'

gem 'jquery-rails'
gem 'html5-rails'
gem 'pjax_rails'
gem 'meta-tags', :require => 'meta_tags'
gem 'rails-timeago'

group :development do
  gem 'sqlite3',      '1.3.5'
  gem 'rspec-rails',  '2.11.0'
  gem 'factory_girl_rails'
  gem 'guard-rspec',  '0.5.5'
  gem 'rails_best_practices'
  gem 'capistrano'
end

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
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
  gem 'capybara',     '1.1.3'
  gem 'guard-spork'
  gem 'spork-rails'
  gem 'launchy'
  gem 'database_cleaner'

  # System-dependent gems
  # Linux
  gem 'rb-inotify', '0.8.8'
  gem 'libnotify',  '0.5.9'

  # Mac OSX
  # gem 'rb-fsevent',   '0.9.1'
  # gem 'growl',        '1.0.3'

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
