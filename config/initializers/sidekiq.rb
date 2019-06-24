require 'syslog/logger'

Sidekiq::Logging.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new('joegattnet_v3_sidekiq'))
