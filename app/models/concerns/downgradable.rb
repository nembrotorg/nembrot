# encoding: utf-8

module Downgradable
  extend ActiveSupport::Concern

  included do
    scope :downgrade_warnable, -> { where('downgrade_warning_at > ?', Time.now) }
    scope :downgradable, -> { where('downgrade_at < ?', Time.now) }
  end

  def self.audit_downgrade_warnings
    downgrade_warnable.each do |user|
      user.warn_about_downgrade
    end
  end

  def self.audit_downgrades
    downgradable.each do |user|
      user.warn_about_downgrade
    end
  end

  def warn_about_downgrade
    PlanMailer.downgrade_warning(user)
    downgrade_warning_at = nil
    save!(validate: false)
  end

  def downgrade
    PlanMailer.downgrade(user)
    plan = Plan.free
    downgrade_warning_at = nil
    downgrade_at = nil
    deactivate_extra_channels
    downgrade_themes
    save!(validate: false)
  end

  def downgrade_themes
    channels.premium_themed.each do |channel|
      channel.theme = Channel.default.theme if channel.theme.premium?
      channel.save!
    end
  end

  def deactivatable
    channels.offset(Plan.free.max_channels)
  end

  def deactivate_extra_channels
    deactivatable.each do |channel|
      channel.active = false
      channel.save!
    end
  end
end
