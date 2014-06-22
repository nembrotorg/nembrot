# encoding: utf-8

module Upgradable
  extend ActiveSupport::Concern

  #private

  def update_from_paypal_callback!(params)
    new_plan = Plan.find_from_payment(params[:cc], params[:amt])
    if new_plan.nil?
      PAY_LOG.error "No plan found with #{ params[:cc] } #{ params[:amt] }. (Callback tx: #{ params[:tx] }.)"
    else
      skip_confirmation!
      update_attributes(
        downgrade_at: 1.day.from_now,
        downgrade_warning_at: 3.hours.from_now,
        paypal_last_tx: params[:tx],
        plan: new_plan,
        unconfirmed_email: nil)
      save!(validate: false)
      PAY_LOG.info "User #{ id } provisionally upgraded to #{ plan.name } from paypal callback."
    end
  end

  def update_from_paypal_pdt!(params)
    new_plan = Plan.find_from_payment(params[:mc_currency], params[:payment_gross])
    if new_plan.nil?
      PAY_LOG.error "No plan found with #{ params[:mc_currency] } #{ params[:payment_gross] }. (PDT.)"
    else
      skip_confirmation!
      update_attributes(
        downgrade_at: 2.weeks.from_now,
        downgrade_warning_at: 1.week.from_now,
        paypal_email: params[:payer_email],
        first_name: params[:first_name],
        last_name: params[:last_name],
        plan: new_plan,
        unconfirmed_email: nil)
      save!(validate: false)
      PAY_LOG.info "User #{ id } provisionally upgraded to #{ plan.name } from paypal PDT."
    end
  end

  def update_subscription_from_paypal_ipn!(params)
    new_plan = Plan.find_from_payment(params[:mc_currency], params[:payment_gross])
    if new_plan.nil?
      PAY_LOG.error "No plan found with #{ params[:mc_currency] } #{ params[:payment_gross] }. (PDT.)"
    else
      skip_confirmation!
      update_attributes(
        country: params[:residence_country],
        downgrade_at: nil,
        downgrade_warning_at: nil,
        first_name: params[:first_name],
        last_ipn_txn_type: params[:txn_type],
        last_name: params[:last_name],
        paypal_email: params[:payer_email],
        paypal_last_ipn: params[:ipn_track_id],
        paypal_payer_id: params[:payer_id],
        paypal_subscriber_id: params[:subscr_id],
        plan: Plan.find_from_payment(params[:mc_currency], params[:mc_amount3]),
        subscription_term_days: params[:period3] == '1 Y' ? 365 : 31,
        unconfirmed_email: nil)
      save!(validate: false)
      PlanMailer.successful_upgrade(self).deliver
      PAY_LOG.info "User #{ id } upgrade to #{ plan.name } confirmed by IPN. (IPN track id: #{ params[:ipn_track_id] }.)"
    end
  end

  def update_payment_from_paypal_ipn!(params)
    new_plan = Plan.find_from_payment(params[:mc_currency], params[:payment_gross])
    term_days = (params[:item_number].include? 'yearly') ? 365 : 31
    if new_plan.nil?
      PAY_LOG.error "No plan found with #{ params[:mc_currency] } #{ params[:payment_gross] }. (PDT.)"
    else
      skip_confirmation!
      update_attributes(
        country: params[:residence_country],
        downgrade_at: (term_days + 7).days.from_now,
        downgrade_warning_at: term_days.days.from_now,
        first_name: params[:first_name],
        last_ipn_txn_type: params[:txn_type],
        last_name: params[:last_name],
        paypal_email: params[:payer_email],
        paypal_last_ipn: params[:ipn_track_id],
        paypal_payer_id: params[:payer_id],
        paypal_subscriber_id: params[:subscr_id],
        plan: Plan.find_from_payment(params[:mc_currency], params[:mc_gross]),
        subscription_term_days: term_days,
        unconfirmed_email: nil)
      save!(validate: false)
      PlanMailer.successful_upgrade(self).deliver
      PAY_LOG.info "User #{ id } payment for #{ plan.name } confirmed by IPN. (IPN track id: #{ params[:ipn_track_id] }.)"
    end
  end

  def update_cancellation_from_paypal_ipn!(params)
    skip_confirmation!
    # This is just for our own records. We will let the term expire.
    update_attributes(
      last_ipn_txn_type: params[:txn_type],
      paypal_cancelled_at: Time.now,
      paypal_last_ipn: params[:ipn_track_id]
    )
    save!(validate: false)
    PAY_LOG.info "User #{ id } cancelled subscription. (IPN track id: #{ params[:ipn_track_id] }.)"
  end
end
