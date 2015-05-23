guard 'bundler' do
  watch('Gemfile')
end

guard :rspec, cmd: 'bin/rspec --format Fuubar --color', all_after_pass: false, all_after_fail: false do
    watch('spec/spec_helper.rb') { 'spec' }

    watch(%r{^spec/controllers/.+_spec\.rb$})
    watch(%r{^spec/models/.+_spec\.rb$})
    watch(%r{^spec/helpers/.+_spec\.rb$})
    watch(%r{^spec/mailers/.+_spec\.rb$})
    watch(%r{^spec/routing/.+_spec\.rb$})
    watch(%r{^spec/requests/.+_spec\.rb$})
    watch(%r{^spec/features/.+_spec\.rb$})

    watch(%r{^app/models/(.+)\.rb$}) { |m| "spec/models/#{m[1]}_spec.rb" }
    watch(%r{^app/helpers/(.+)\.rb$}) { |m| "spec/helpers/#{m[1]}_spec.rb" }
    watch(%r{^app/mailers/(.+)\.rb$}) { |m| "spec/mailers/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$}) do |m|
      [
        "spec/routing/#{m[1]}_spec.rb",
        "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb"
      ]
    end

    watch(%r{^app/views/(.+)\.\.html\.slim$}) { |m| "spec/requests/#{m[1]}_spec.rb" }
    watch(%r{^app/views/(.+)\.\.html\.slim$}) { |m| "spec/features/#{m[1]}_spec.rb" }

    watch(%r{^spec/support/(.+)\.rb$}) { "spec" }
    watch('config/routes.rb') { "spec/routing" }
    watch('app/controllers/application_controller.rb') { "spec/controllers" }

    watch(%r{^spec/lib/.+_integration_spec\.rb$})
end

#guard :rubocop, all_on_start: false, notification: true do
#  watch(%r{.+\.rb$})
#  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
#end

guard :livereload do
  watch(%r{app/views/.+\.slim$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html))).*}) { |m| "/assets/#{m[3]}" }
end

# guard 'sass', :input => 'sass', :output => 'css', :noop => true, :hide_success => true
# guard 'coffeescript', :input => 'app/assets/javascripts', :noop => true, :hide_success => true
