pay_logfile = File.open("#{ Rails.root }/log/pay.log", 'a')
pay_logfile.sync = true
PAY_LOG = PayLogger.new(pay_logfile)

sync_logfile = File.open("#{ Rails.root }/log/sync.log", 'a')
sync_logfile.sync = true
SYNC_LOG = SyncLogger.new(sync_logfile)
