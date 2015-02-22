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
    PAY_LOG.info "User #{ id } warned about downgrade."
  end

  def downgrade
    PlanMailer.downgrade(self).deliver
    self.downgrade_at = nil
    self.downgrade_warning_at = nil
    self.last_ipn_txn_type = nil
    self.paypal_cancelled_at = nil
    self.paypal_last_ipn = nil
    self.paypal_last_tx = nil
    self.paypal_payer_id = nil
    self.paypal_subscriber_id = nil
    self.plan = Plan.free
    self.subscription_term_days = nil
    self.token_for_paypal = generate_token
    deactivate_extra_channels
    downgrade_themes
    save!(validate: false)
    PAY_LOG.info "User #{ id } downgraded."
  end

  def downgrade_themes
    PAY_LOG.info "User #{ id }: de-theming #{ channels.premium_themed.size } channels."
    channels.premium_themed.each do |channel|
      channel.theme = Channel.default.theme if channel.theme.premium?
      channel.save!
    end
  end

  def deactivatable
    channels.offset(Plan.free.max_channels)
  end

  def deactivate_extra_channels
    PAY_LOG.info "User #{ id }: deactivating #{ deactivatable.size } channels."
    deactivatable.each do |channel|
      channel.active = false
      channel.save!
    end
  end
end
