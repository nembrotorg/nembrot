module SyncHelper
  def dirtify
    self.update_attributes!(:dirty => true , :attempts => 0)
  end

  def undirtify
    self.update_attributes!(:dirty => false , :attempts => 0)
  end

  def increment_attempts
    self.increment!(:attempts)
  end

  def max_out_attempts
    self.update_attributes!(:attempts => Settings.notes.attempts + 1)
  end
end