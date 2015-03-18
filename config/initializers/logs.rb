sync_logfile = File.open("#{ Rails.root }/log/sync.log", 'a')
sync_logfile.sync = true
SYNC_LOG = SyncLogger.new(sync_logfile)
