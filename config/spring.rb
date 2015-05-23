# ENV['RAILS_ENV'] ||= 'test'

# unless ENV['DRB']
#   require 'simplecov'
#   SimpleCov.start 'rails'
#   require File.expand_path('../../config/environment', __FILE__)
# end

# require 'rspec/rails'
# require 'capybara/rails'
# require 'capybara/rspec'
# require 'paper_trail/frameworks/rspec'

# # files to preload based on results of Kernel override code below
# # ie they took more than 100 ms to load
# require 'sprockets'
# require 'sprockets/eco_template'
# require 'sprockets/base'
# require 'mime/types'
# require 'treetop/runtime'
# require 'database_cleaner'
# # require 'active_record/connection_adapters/postgresql_adapter'
# require 'tzinfo'
# require 'mail'
# # require 'tilt'
# # require 'journey'
# # require 'journey/router'
# # require 'haml/template'

# Capybara.javascript_driver = :webkit

# RSpec.configure do |config|
#   config.mock_with :rspec

#   # If you're not using ActiveRecord, or you'd prefer not to run each of your
#   # examples within a transaction, remove the following line or assign false
#   # instead of true.
#   config.use_transactional_fixtures = false

#   # If true, the base class of anonymous controllers will be inferred
#   # automatically. This will be the default behavior in future versions of
#   # rspec-rails.
#   config.infer_base_class_for_anonymous_controllers = false

#   config.include FactoryGirl::Syntax::Methods

#   config.before :suite do
#     # PerfTools::CpuProfiler.start("/tmp/rspec_profile")
#     DatabaseCleaner.strategy = :transaction
#     DatabaseCleaner.clean_with(:truncation)
#   end

#   # Request specs cannot use a transaction because Capybara runs in a
#   # separate thread with a different database connection.
#   config.before type: :request do
#     DatabaseCleaner.strategy = :truncation
#   end

#   # Reset so other non-request specs don't have to deal with slow truncation.
#   config.after type: :request  do
#     DatabaseCleaner.strategy = :transaction
#   end

#   RESERVED_IVARS = %w(@loaded_fixtures)
#   last_gc_run = Time.now

#   config.before(:example) do
#     GC.disable
#   end

#   config.before do
#     DatabaseCleaner.start
#   end

#   config.after do
#     DatabaseCleaner.clean
#   end

#   # Release instance variables and trigger garbage collection
#   # manually every second to make tests faster
#   # http://blog.carbonfive.com/2011/02/02/crank-your-specs/
#   config.after(:example) do
#     (instance_variables - RESERVED_IVARS).each do |ivar|
#       instance_variable_set(ivar, nil)
#     end
#     if Time.now - last_gc_run > 1.0
#       GC.enable
#       GC.start
#       last_gc_run = Time.now
#     end
#   end

#   config.after :suite do
#     # PerfTools::CpuProfiler.stop

#     # REPL to query ObjectSpace
#     # http://blog.carbonfive.com/2011/02/02/crank-your-specs/
#     # while true
#     #   '> '.display
#     #   begin
#     #     puts eval($stdin.gets)
#     #   rescue Exception => e
#     #     puts e.message
#     #   end
#     # end
#   end

#   # This is a provisional fix for an rspec-rails issue
#   # (see https://github.com/rspec/rspec-rails/issues/476).
#   # It allows for a proper test execution with `config.threadsafe!`.
#   ActionView::TestCase::TestController.instance_eval do
#     helper Rails.application.routes.url_helpers# , (append other helpers you need)
#   end
#   ActionView::TestCase::TestController.class_eval do
#     def _routes
#       Rails.application.routes
#     end
#   end


#   # rspec-rails 3 will no longer automatically infer an example group's spec type
#   # from the file location. You can explicitly opt-in to the feature using this
#   # config option.
#   # To explicitly tag specs without using automatic inference, set the `:type`
#   # metadata manually:
#   #
#   #     describe ThingsController, :type => :controller do
#   #       # Equivalent to being in spec/controllers
#   #     end
#   config.infer_spec_type_from_file_location!
# end

# Find files to put into preload
# http://www.opinionatedprogrammer.com/2011/02/profiling-spork-for-faster-start-up-time/
# module Kernel
#   def require_with_trace(*args)
#     start = Time.now.to_f
#     @indent ||= 0
#     @indent += 2
#     require_without_trace(*args)
#     @indent -= 2
#     duration = ((Time.now.to_f - start)*1000).to_i
#     if (duration > 100)
#       Kernel::puts "#{ ' ' * @indent }#{ duration } #{ args[0] }"
#     end
#   end
#   alias_method_chain :require, :trace
# end
