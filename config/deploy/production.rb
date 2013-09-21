set :branch,          "origin/master"
set :rails_env,       "production"
set :deploy_to,       "/home/deployer/apps/#{ Settings.app_name }"

set :application, Settings.app_name

default_environment["RAILS_ENV"] = 'production'

default_environment["PATH"]         = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }/bin:/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }/bin:/usr/local/rvm/rubies/ruby-2.0.0-p195/bin:/usr/local/rvm/bin:$PATH"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }:/usr/local/rvm/gems/ruby-2.0.0-p195@#{ Settings.app_name }"
default_environment["RUBY_VERSION"] = "ruby-2.0.0-p195"
