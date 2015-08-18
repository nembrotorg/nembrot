# encoding: utf-8

module Syncable
  extend ActiveSupport::Concern

  included do
    scope :maxed_out, -> { where('attempts > ?', NB.attempts.to_i).order('updated_at') }
    scope :need_syncdown, -> { where('dirty = ? AND attempts <= ? AND try_again_at < ?', true, NB.attempts.to_i, Time.now).order('updated_at') }
  end

  def dirtify(save_it = true)
    self.dirty = true
    self.attempts = 0
    self.try_again_at = Time.now
    self.save! if save_it
  end

  def undirtify(save_it = true)
    self.dirty = false
    self.attempts = 0
    self.try_again_at = 100.years.from_now
    self.save! if save_it
  end

  def increment_attempts
    self.increment!(:attempts)
    self.try_again_at = (10**attempts).minutes.from_now
  end

  def max_out_attempts
    self.update_attributes!(attempts: NB.attempts.to_i + 1)
  end

  def merge(new_values, overwrite = false, object = self)
    new_values.each do |key, value|
      value.strip! if value.is_a? String
      # REVIEW
      #  We can have various strategies here
      #  object.send("#{ key }=", value) if !value.nil? && (object.send("#{ key }").nil? || overwrite)
      #  The one shown above, for instance, resulted in introductions not being removed when removed from Evernote
      #  Create test for the above scenario.
      object.send("#{ key }=", value) if !value.nil? || overwrite
    end unless new_values.blank?
  end
end
