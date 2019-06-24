# config valid only for current version of Capistrano
lock '3.4.0'

server 'joegatt.org', user: 'deployer', roles: %w{app db web}

set :repo_url, 'git@github.com:joegattnet/joegattnet_v3.git'

set :ssh_options, { forward_agent: true, keys: ["config/deploy_id_rsa"] } if File.exist?("config/deploy_id_rsa")

# FIXME: This needs to be hidden
set :slack_webhook, 'https://hooks.slack.com/services/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'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/application.yml', 'config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public')

# Default value for default_env is {}
# set :default_env, 'staging'

# Default value for keep_releases is 5
# set :keep_releases, 3

set :rvm_ruby_version, '2.1.5'

set :datadog_api_key, 'd61c085faa7b4c1686333e3eafd1fb3e'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end
