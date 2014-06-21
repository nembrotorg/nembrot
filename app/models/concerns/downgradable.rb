# encoding: utf-8

module Downgradable
  extend ActiveSupport::Concern

  included do
    scope :downgrade_warnable, -> { where('downgrade_warning_at < ?', Time.now) }
    scope :downgradable, -> { where('downgrade_at < ?', Time.now) }
  end

  module ClassMethods
    def audit_downgrade_warnings
      self.downgrade_warnable.each do |user|
        user.warn_about_downgrade
      end
    end

    def audit_downgrades
      self.downgradable.each do |user|
        user.downgrade
      end
    end
  end

  def warn_about_downgrade
    PlanMailer.downgrade_warning(self).deliver
    self.downgrade_warning_at = nil
    save!(validate: false)
  end

  def downgrade
    PlanMailer.downgrade(self).deliver
    self.plan = Plan.free
    self.downgrade_warning_at = nil
    self.downgrade_at = nil
    deactivate_extra_channels
    downgrade_themes
    save!(validate: false)
  end

  def downgrade_themes
    channels.premium_themed.each do |channel|
      self.channel.theme = Channel.default.theme if channel.theme.premium?
      channel.save!
    end
  end

  def deactivatable
    channels.offset(Plan.free.max_channels)
  end

  def deactivate_extra_channels
    deactivatable.each do |channel|
      self.channel.active = false
      channel.save!
    end
  end
end
