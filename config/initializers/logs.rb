sync_logfile = File.open("#{ Rails.root }/log/sync.log", 'a')
sync_logfile.sync = true
SYNC_LOG = SyncLogger.new(sync_logfile)

pantography_logfile = File.open("#{ Rails.root }/log/pantography.log", 'a')
pantography_logfile.sync = true
PANTOGRAPHY_LOG = PantographyLogger.new(pantography_logfile)
