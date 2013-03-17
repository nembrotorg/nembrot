source 'https://rubygems.org'

gem 'rails',          '3.2.11'

gem 'thin'
gem 'unicorn'

gem 'devise'
gem 'rails_admin'

gem 'attr_encrypted'
gem 'friendly_id',          '~> 4.0.1'
gem 'acts-as-taggable-on',  '~> 2.3.3'
gem 'paper_trail'
gem 'settingslogic'
gem 'rmagick'

gem 'wtf_lang'

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
gem 'gmaps4rails'
gem 'wikipedia-client'

gem 'daemons'

gem 'coveralls', require: false

group :development do
  gem 'sqlite3'
  gem 'flog'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'rails_best_practices'
  gem 'capistrano'
end

group :assets do
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'sass-rails'
  gem 'compass-rails'
  gem 'compass-h5bp'
  gem 'turbo-sprockets-rails3'
end

# Test set-up from http://ruby.railstutorial.org/chapters/static-pages#sec:guard
# And http://everydayrails.com/2012/03/12/testing-series-rspec-setup.html
group :test do
  gem 'sqlite3'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'spork-rails'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'simplecov', :require => false

  # System-dependent gems
  # Linux
  gem 'rb-inotify', '~> 0.9'
  gem 'libnotify'

  # Mac OSX
  # gem 'rb-fsevent',   '0.9.1'
  # gem 'growl',        '1.0.3'

  # Windows
  # gem 'rb-fchange', '0.0.5'
  # gem 'rb-notifu',  '0.0.4'
  # gem 'win32console', '1.3.0'
end

group :staging, :production do
  gem 'libv8', '~> 3.11.8.3', :platform => :ruby
  gem 'therubyracer', '~> 0.11.1'
  gem 'pg'
end
