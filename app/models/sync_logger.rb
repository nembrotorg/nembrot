class SyncLogger < Logger
  def format_message(severity, timestamp, _progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end
