# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :validate_authorization_for_user, only: [:edit, :update]

  skip_before_filter :verify_authenticity_token, only: [:paypal]

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def upgrade
    # Temporarily upgrades user's account (pending IPN)
    users = User.where(token_for_paypal: params[:cm])

    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:cm] }."
      flash[:error] = 'An error has occurred!'
      redirect_to home_url
      return
    end

    if params[:st] == 'Completed' && !users.empty?
      user = users.first
      user.expires_at = 1.hour.from_now
      new_plan = Plan.find_from_payment(params[:cc], params[:amt])
      if new_plan.nil?
        PAY_LOG.error "No plan found with #{ params[:mc_currency] } #{ params[:mc_amount3] }. (IPN id: #{ params[:ipn_track_id] }.)"
        return
      end
      user.plan = new_plan
      user.save!(validate: false)
      PAY_LOG.info "User #{ user.id } provisionally upgraded to #{ user.plan.name } by browser redirect."
      redirect_to home_url, notice: 'You are now a Premium user. Thanks!'
      return
    else
      flash[:error] = 'Your upgrade was cancelled.'
      PAY_LOG.info "User #{ users.first.id } upgrade cancelled by browser redirect. (Status: params[:st].)"
      redirect_to home_url
      return
    end
  end

  def cancel_upgrade
    PAY_LOG.info "User #{ user.id } upgrade cancelled by user at PayPal site." # TODO: Add Google Analytics
    flash[:error] = 'Your upgrade was cancelled.'
    redirect_to home_url
  end

  def paypal
    # Ensure that this IPN has not already been processed
    ipn_not_repeated = (User.where(paypal_last_ipn: params[:ipn_track_id])).empty?
    verified_ipn_message = Paypal.verify(params)

    if ipn_not_repeated && verified_ipn_message
      # REVIEW: Change this if we're not processing more types here
      case params[:txn_type]
        when 'subscr_signup'
          user = User.where(token_for_paypal: params[:custom]).first
          if user.nil?
            PAY_LOG.error "No user found with token: #{ params[:custom] }. (IPN id: #{ params[:ipn_track_id] }.)"
            return
          end
          new_plan = Plan.find_from_payment(params[:mc_currency], params[:mc_amount3])
          if new_plan.nil?
            PAY_LOG.error "No plan found with #{ params[:mc_currency] } #{ params[:mc_amount3] }. (IPN id: #{ params[:ipn_track_id] }.)"
            return
          end
          user.update_from_paypal_signup(params, new_plan) unless new_plan.nil? || user.nil?
          PAY_LOG.info "User #{ user.id } upgrade to #{ user.plan.name } confirmed by IPN."
      end
    else
      PAY_LOG.warn "Repeat IPN received from Paypal. (IPN id: #{ params[:ipn_track_id] }.)" unless ipn_not_repeated
      PAY_LOG.warn "Paypal IPN failed verification. (IPN id: #{ params[:ipn_track_id] }.)" unless verified_ipn_message
    end

    render nothing: true, status: 200
  end

  def menu
    @channels_owned_by_current_user = Channel.where(user: current_user).pluck(:slug) if user_signed_in? 
    render partial: 'user_tools'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def validate_authorization_for_user
    redirect_to root_path unless @user == current_user
  end
end
