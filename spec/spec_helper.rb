# From http://stackoverflow.com/questions/11377460

require 'rubygems'
require 'spork'
require 'simplecov'

# See https://coveralls.io
require 'coveralls'
Coveralls.wear!

#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

# Workaround for issue #109 until pull-req #140 gets merged
# See https://github.com/sporkrb/spork/pull/140
AbstractController::Helpers::ClassMethods.module_eval do 
  def helper(*args, &block)
    modules_for_helpers(args).each {|mod| add_template_helper(mod)}
    _helpers.module_eval(&block) if block_given?
  end 
end if Spork.using_spork?

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  unless ENV['DRB']
    SimpleCov.start 'rails'
    require File.expand_path("../../config/environment", __FILE__)
  end

  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rails'
  require 'capybara/rspec'

  # files to preload based on results of Kernel override code below
  # ie they took more than 100 ms to load
  require 'sprockets'
  require 'sprockets/eco_template'
  require 'sprockets/base'
  require 'mime/types'
  require 'treetop/runtime'
  require 'database_cleaner'
  #require 'active_record/connection_adapters/postgresql_adapter'
  require 'tzinfo'
  require 'mail'
  #require 'tilt'
  #require 'journey'
  #require 'journey/router'
  require 'haml/template'

  RSpec.configure do |config|
    config.mock_with :rspec

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.include FactoryGirl::Syntax::Methods

    config.before :suite do
      # PerfTools::CpuProfiler.start("/tmp/rspec_profile")
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    # Request specs cannot use a transaction because Capybara runs in a
    # separate thread with a different database connection.
    config.before type: :request do
      DatabaseCleaner.strategy = :truncation
    end

    # Reset so other non-request specs don't have to deal with slow truncation.
    config.after type: :request  do
      DatabaseCleaner.strategy = :transaction
    end

    RESERVED_IVARS = %w(@loaded_fixtures)
    last_gc_run = Time.now

    config.before(:each) do
      GC.disable
    end

    config.before do
      DatabaseCleaner.start
    end

    config.after do
      DatabaseCleaner.clean
    end

    # Release instance variables and trigger garbage collection
    # manually every second to make tests faster
    # http://blog.carbonfive.com/2011/02/02/crank-your-specs/
    config.after(:each) do
      (instance_variables - RESERVED_IVARS).each do |ivar|
        instance_variable_set(ivar, nil)
      end
      if Time.now - last_gc_run > 1.0
        GC.enable
        GC.start
        last_gc_run = Time.now
      end
    end

    config.after :suite do
      # PerfTools::CpuProfiler.stop

      # REPL to query ObjectSpace
      # http://blog.carbonfive.com/2011/02/02/crank-your-specs/
      # while true
      #   '> '.display
      #   begin
      #     puts eval($stdin.gets)
      #   rescue Exception => e
      #     puts e.message
      #   end
      # end
    end
  end

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
end

Spork.each_run do
  # This code will be run each time you run your specs.
  if ENV['DRB']
    SimpleCov.start 'rails'
    Nembrot::Application.initialize!
    class Nembrot::Application
      def initialize!; end
    end
  end

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  FactoryGirl.reload
  I18n.backend.reload!
end
