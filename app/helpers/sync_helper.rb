# encoding: utf-8

module SyncHelper
  def dirtify(save_it = true)
    self.dirty = true
    self.attempts = 0
    self.save! if save_it
  end

  def undirtify(save_it = true)
    self.dirty = false
    self.attempts = 0
    self.save! if save_it
  end

  def increment_attempts
    self.increment!(:attempts)
  end

  def max_out_attempts
    self.update_attributes!(attempts: Settings.notes.attempts + 1)
  end
end
