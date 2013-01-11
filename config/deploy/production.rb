set :branch,          "origin/master"
set :rails_env,       "production"
set :deploy_to,       "/home/deployer/apps/joegattnet_v3"

set :application, "joegattnet_v3"

default_environment["RAILS_ENV"] = 'production'

default_environment["PATH"]         = "/usr/local/rvm/gems/ruby-1.9.3-p362@joegattnet_v3/bin:/usr/local/rvm/gems/ruby-1.9.3-p362@joegattnet_v3/bin:/usr/local/rvm/rubies/ruby-1.9.3-p362/bin:/usr/local/rvm/bin:$PATH"
default_environment["GEM_HOME"]     = "/usr/local/rvm/gems/ruby-1.9.3-p362@joegattnet_v3"
default_environment["GEM_PATH"]     = "/usr/local/rvm/gems/ruby-1.9.3-p362@joegattnet_v3:/usr/local/rvm/gems/ruby-1.9.3-p362@joegattnet_v3"
default_environment["RUBY_VERSION"] = "ruby-1.9.3-p362"
