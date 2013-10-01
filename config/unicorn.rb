# Set environment to development unless something else is specified
env = ENV["RAILS_ENV"] || "development"

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 4

# Preload our app for more speed
preload_app true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# Production specific settings
if env == "production"
  pid "/tmp/unicorn.joegattnet_v3.pid"

  # listen on both a Unix domain socket and a TCP port,
  # we use a shorter backlog for quicker failover when busy
  listen "/tmp/joegattnet_v3.socket", :backlog => 64

  # Help ensure your application will always spawn in the symlinked
  # "current" directory that Capistrano sets up.
  working_directory "/home/deployer/apps/joegattnet_v3/current"

  # feel free to point this anywhere accessible on the filesystem
  user 'deployer', 'staff'
  shared_path = "/home/deployer/apps/joegattnet_v3/shared"

  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
else
  pid "/tmp/unicorn.joegattnet_v3_staging.pid"

  # listen on both a Unix domain socket and a TCP port,
  # we use a shorter backlog for quicker failover when busy
  listen "/tmp/joegattnet_v3_staging.socket", :backlog => 64

  # Staging
  working_directory "/home/deployer/apps/joegattnet_v3_staging/current"
  user 'deployer', 'staff'
  shared_path = "/home/deployer/apps/joegattnet_v3_staging/shared"
  stderr_path "#{shared_path}/log/unicorn.stderr.log"
  stdout_path "#{shared_path}/log/unicorn.stdout.log"
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  if env == "production"
    old_pid = "/tmp/unicorn.joegattnet_v3.pid.oldbin"
  else
    old_pid = "/tmp/unicorn.joegattnet_v3_staging.pid.oldbin"
  end
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
