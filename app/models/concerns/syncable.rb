# encoding: utf-8

module Syncable
  extend ActiveSupport::Concern

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
    self.update_attributes!(attempts: Settings.channel.attempts + 1)
  end

  def merge(new_values, overwrite = false, object = self)
    new_values.each do |key, value|
      value.strip! if value.is_a? String
      object.send("#{ key }=", value) if !value.nil? && (object.send("#{ key }").nil? || overwrite)
    end unless new_values.blank?
  end

end