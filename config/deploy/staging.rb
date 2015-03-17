set :branch,      'origin/staging'
set :rails_env,   'staging'
set :deploy_to,   '/home/deployer/apps/nembrot_staging'

set :application, 'nembrot_staging'

default_environment['RAILS_ENV'] = 'staging'

default_environment['PATH']         = '/usr/local/rvm/gems/ruby-2.1.5-p273@nembrot_staging/bin:/usr/local/rvm/gems/ruby-2.1.5-p273@nembrot_staging/bin:/usr/local/rvm/rubies/ruby-2.1.5-p273/bin:/usr/local/rvm/bin:$PATH'
default_environment['GEM_HOME']     = '/usr/local/rvm/gems/ruby-2.1.5-p273@nembrot_staging'
default_environment['GEM_PATH']     = '/usr/local/rvm/gems/ruby-2.1.5-p273@nembrot_staging:/usr/local/rvm/gems/ruby-2.1.5-p273@nembrot_staging'
default_environment['RUBY_VERSION'] = 'ruby-2.1.5-p273'
