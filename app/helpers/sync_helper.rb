module SyncHelper
  def dirtify(save_it = true)
    dirty = true
    attempts = 0
    save! if save_it
  end

  def undirtify(save_it = true)
    dirty = false
    attempts = 0
    save! if save_it
  end

  def increment_attempts
    increment!(:attempts)
  end

  def max_out_attempts
    update_attributes!(:attempts => Settings.notes.attempts + 1)
  end
end
