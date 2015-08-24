class SyncResourceJob < ActiveJob::Base
  queue_as :default

  def perform(resource)
    resource.sync_binary
  end
end
