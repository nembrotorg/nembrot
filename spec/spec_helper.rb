require 'rubygems'
require 'spork'
require 'capybara/rspec'
require 'database_cleaner'
require 'webmock/rspec'

# Workaround for issue #109 until pull-req #140 gets merged
# See https://github.com/sporkrb/spork/pull/140
AbstractController::Helpers::ClassMethods.module_eval do 
  def helper(*args, &block)
    modules_for_helpers(args).each {|mod| add_template_helper(mod)}
    _helpers.module_eval(&block) if block_given?
  end 
end if Spork.using_spork?

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  RSpec.configure do |config|
    config.mock_with :rspec

    config.use_transactional_fixtures = true

    # Tweaks Garbage Collection to speed up tests
    # See: http://ariejan.net/2011/09/24/rspec-speed-up-by-tweaking-ruby-garbage-collection
    config.before(:all) do
      DeferredGarbageCollection.start
    end

    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end

    # Cleaning database
    # See http://asciicasts.com/episodes/257-request-specs-and-capybara
    config.before(:suite) do  
      DatabaseCleaner.strategy = :truncation  
    end  
      
    config.before(:each) do  
      DatabaseCleaner.start  
    end  
      
    config.after(:each) do  
      DatabaseCleaner.clean  
    end 
  end
end

Spork.each_run do
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  DatabaseCleaner.clean
end
