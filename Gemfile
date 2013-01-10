source 'https://rubygems.org'

gem 'rails',          '3.2.10'

gem 'thin'
gem 'unicorn'

gem 'devise'
gem 'rails_admin'

gem 'attr_encrypted'
gem 'friendly_id',          '~> 4.0.1'
gem 'acts-as-taggable-on',  '~> 2.3.3'
gem 'paper_trail'
gem 'settingslogic'

gem 'evernote-thrift'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-evernote'

gem 'differ'
gem 'nokogiri'

gem 'haml'
gem 'haml-rails'
gem 'html5-rails'

gem 'json'

gem 'jquery-rails'
gem 'pjax_rails'
gem 'meta-tags', :require => 'meta_tags'
gem 'breadcrumbs_on_rails'
gem 'rails-timeago'
gem 'wikipedia-client'

group :development do
  gem 'sqlite3',      '1.3.5'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'rails_best_practices'
  gem 'capistrano'
  gem 'webmock'
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
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'capybara',     '1.1.3'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
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
  #gem 'libv8', '~> 3.11.8'
  gem 'therubyracer', :require => 'v8'
  gem 'pg'
end
