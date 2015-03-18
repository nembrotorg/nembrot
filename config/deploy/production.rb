set :branch,      'origin/master'
set :rails_env,   'production'
set :deploy_to,   '/home/deployer/apps/joegattnet_v3'

set :application, 'joegattnet_v3'

default_environment['RAILS_ENV'] = 'production'

default_environment['PATH']         = '/usr/local/rvm/gems/ruby-2.1.5@joegattnet_v3/bin:/usr/local/rvm/gems/ruby-2.1.5@joegattnet_v3/bin:/usr/local/rvm/rubies/ruby-2.1.5/bin:/usr/local/rvm/bin:$PATH'
default_environment['GEM_HOME']     = '/usr/local/rvm/gems/ruby-2.1.5@joegattnet_v3'
default_environment['GEM_PATH']     = '/usr/local/rvm/gems/ruby-2.1.5@joegattnet_v3:/usr/local/rvm/gems/ruby-2.1.5@joegattnet_v3'
default_environment['RUBY_VERSION'] = 'ruby-2.1.5'
