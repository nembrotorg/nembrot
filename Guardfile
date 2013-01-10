guard 'bundler' do
  watch('Gemfile')
end

guard 'spork', wait: 60, cucumber: false, rspec: true, test_unit: false do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('spec/spec_helper.rb')
end

guard 'rspec', :cli => "--drb --format progress --color", :all_after_pass => false do
    watch('spec/spec_helper.rb') { "spec" }

    watch(%r{^spec/controllers/.+_spec\.rb$})
    watch(%r{^spec/models/.+_spec\.rb$})
    watch(%r{^spec/helpers/.+_spec\.rb$})
    watch(%r{^spec/routing/.+_spec\.rb$})
    watch(%r{^spec/requests/.+_spec\.rb$})

    watch(%r{^app/models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }
    watch(%r{^app/helpers/(.+)\.rb$}) { |m| "spec/helpers/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$}) do |m|
      [
        "spec/routing/#{m[1]}_spec.rb",
        "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"
      ]
    end

    # These tests should be in features (Capybara)
    watch(%r{^app/views/(.+)\.\.html\.haml$}) { |m| "spec/requests/#{m[1]}_spec.rb" }

    watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
    watch('config/routes.rb') { "spec/routing" }
    watch('app/controllers/application_controller.rb') { "spec/controllers" }

    watch(%r{^spec/lib/.+_integration_spec\.rb$})
end
