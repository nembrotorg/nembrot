source 'https://rubygems.org'

# REVIEW: Some gems are listed more than once. Travis warns about it.

gem 'rails',          '4.2.1'

gem 'activerecord-session_store'
gem 'acts-as-taggable-on'
gem 'acts_as_votable'
gem 'attr_encrypted'
gem 'breadcrumbs_on_rails'
gem 'cancan'
gem 'coffee-rails'
gem 'commontator'
gem 'compass-rails', '~> 2.0.0'
gem 'dalli'
gem 'detect_language'
gem 'devise'
gem 'differ'
gem 'dogapi'
gem 'embiggen'
gem 'flexslider'
gem 'jquery-dotdotdot-rails'
gem 'jquery-rails-cdn'
gem 'evernote-thrift'
gem 'figaro'
gem 'friendly_id'
gem 'gmaps4rails'
gem 'god'
gem 'httparty'
# gem 'image_optim'
gem 'isbn_validation'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'json'
gem 'kaminari'
gem 'kgio'
gem 'levenshtein-ffi', require: 'levenshtein'
gem 'meta-tags', require: 'meta_tags'
gem 'mini_magick'
gem 'nokogiri'
# gem 'oauth'
# gem 'omniauth'
gem 'omniauth-evernote'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-gplus'
gem 'omniauth-linkedin'
gem 'omniauth-twitter'
gem 'paper_trail'
gem 'pjax_rails'
gem 'pismo'
gem 'rails-timeago'
gem 'safe_yaml'
gem 'sass-rails', github: 'rails/sass-rails', branch: '4-0-stable'
gem 'sidekiq'
gem 'sitemap_generator'
gem 'slim-rails'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'susy'
gem 'thin'
gem 'twitter', git: 'https://github.com/sferik/twitter.git'
gem 'uglifier'
gem 'underscore-rails'
gem 'unicorn'
gem 'uuidtools'
gem 'validate_url'
gem 'whenever', require: false

group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'sqlite3'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano',           require: false
  gem 'capistrano-bundler',   require: false
  gem 'capistrano-rails',     require: false
  gem 'capistrano-rvm',       require: false
  gem 'flog'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  # gem 'guard-rails_best_practices'
  # gem 'guard-rubocop', require: false
  gem 'guard-sass', require: false
  gem 'rails_best_practices'
end

group :test do
  gem 'capybara'
  gem 'capybara-webkit' # Requires QT, see: https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner',  '1.0.1'  # See https://github.com/bmabey/database_cleaner/issues/224
  gem 'faker'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
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
