# encoding: utf-8

module Syncable
  extend ActiveSupport::Concern

  included do
    scope :need_syncdown, -> { where('dirty = ?', true).order('updated_at') }
  end

  def dirtify(save_it = true)
    self.dirty = true
    self.save! if save_it
  end

  def undirtify(save_it = true)
    self.dirty = false
    self.save! if save_it
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
