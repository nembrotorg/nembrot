set :branch,          "origin/staging"
set :rails_env,       "staging"
set :deploy_to,       "/home/deployer/apps/#{ Settings.app_name }_staging"

set :application, "#{ Settings.app_name }_staging"

default_environment["RAILS_ENV"] = 'staging'

default_environment["PATH"]         = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }_staging/bin:/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }_staging/bin:/usr/local/rvm/rubies/ruby-2.0.0-p195/bin:/usr/local/rvm/bin:$PATH"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }_staging"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }_staging:/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }_staging"
default_environment["RUBY_VERSION"] = "ruby-2.0.0-p195"
