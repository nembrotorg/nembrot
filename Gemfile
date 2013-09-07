source 'https://rubygems.org'

gem 'rails',          '4.0.0'

gem 'acts-as-taggable-on'
gem 'attr_encrypted'
gem 'breadcrumbs_on_rails'
gem 'coffee-rails'
# gem 'compass-rails'- TEMPORARY: This is to enable Rails 4 upgrade
gem 'compass-rails', github: 'milgner/compass-rails', ref: '1749c06f15dc4b058427e7969810457213647fb8'
gem 'compass-h5bp'
gem 'coveralls', require: false
gem 'cancan'
gem 'dalli'
gem 'detect_language'
gem 'devise'
gem 'differ'
gem 'evernote-thrift'
gem 'friendly_id', github: 'norman/friendly_id', branch: 'master'
gem 'gmaps4rails'
gem 'god'
gem 'httparty'
gem 'isbn_validation'
gem 'jquery-rails'
gem 'json'
gem 'kgio'
gem 'meta-tags', require: 'meta_tags'
gem 'mini_magick'
gem 'nokogiri'
gem 'oauth'
gem 'omniauth'
gem 'omniauth-evernote'
gem 'paper_trail', github: 'airblade/paper_trail', branch: 'master'
gem 'pjax_rails'
gem 'rails-timeago'
gem 'safe_yaml'
gem 'sass-rails'
gem 'settingslogic'
gem 'slim'
gem 'slim-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'thin'
gem 'uglifier'
gem 'unicorn'
gem 'validate_url'
gem 'whenever', require: false
gem 'wikipedia-client'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano'
  gem 'factory_girl_rails'
  gem 'flog'
  gem 'fuubar'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  gem 'guard-rubocop'
  gem 'guard-sass', require: false
  gem 'rails_best_practices'
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner',  '1.0.1'  # See https://github.com/bmabey/database_cleaner/issues/224
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fuubar'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'launchy'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'sass-rails'
  gem 'simplecov', require: false
  gem 'spork-rails', :github => 'sporkrb/spork-rails'
  gem 'sqlite3'
  gem 'vcr'
  gem 'webmock'

  # System-dependent gems
  # Linux
  gem 'libnotify'
  gem 'rb-inotify', '~> 0.9'

  # Mac OSX
  # gem 'growl',        '1.0.3'
  # gem 'rb-fsevent',   '0.9.1'

  # Windows
  # gem 'rb-fchange', '0.0.5'
  # gem 'rb-notifu',  '0.0.4'
  # gem 'win32console', '1.3.0'
end

group :staging, :production do
  gem 'pg'
  # Use node.js instead: https://github.com/joyent/node/wiki/Installation
  # gem 'libv8', '~> 3.11.8.3', platform: :ruby
  # gem 'therubyracer', '~> 0.11.1'
end
