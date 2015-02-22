set :branch,      'origin/staging'
set :rails_env,   'staging'
set :deploy_to,   '/home/deployer/apps/nembrotcom_staging'

set :application, 'nembrotcom_staging'

default_environment['RAILS_ENV'] = 'staging'

default_environment['PATH']         = '/usr/local/rvm/gems/ruby-2.0.0-p195@nembrotcom_staging/bin:/usr/local/rvm/gems/ruby-2.0.0-p195@nembrotcom_staging/bin:/usr/local/rvm/rubies/ruby-2.0.0-p195/bin:/usr/local/rvm/bin:$PATH'
default_environment['GEM_HOME']     = '/usr/local/rvm/gems/ruby-2.0.0-p195@nembrotcom_staging'
default_environment['GEM_PATH']     = '/usr/local/rvm/gems/ruby-2.0.0-p195@nembrotcom_staging:/usr/local/rvm/gems/ruby-2.0.0-p195@nembrotcom_staging'
default_environment['RUBY_VERSION'] = 'ruby-2.0.0-p195'
