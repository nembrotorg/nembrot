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

    if params[:st] == 'Completed' && !users.empty?
      user = users.first
      user.expires_at = 1.hour.from_now
      user.plan = Plan.find_from_payment(params[:cc], params[:amt])
      user.save!(validate: false)
      redirect_to home_url, notice: 'You are now a Premium user. Thanks!'
    else
      flash[:error] = 'Your upgrade was cancelled.'
      redirect_to home_url
    end
  end

  def cancel_upgrade
    flash[:error] = 'Your upgrade was cancelled.'
    redirect_to home_url
  end

  def paypal
    # Ensure that this IPN has not already been processed
    if (User.where(paypal_last_ipn: params[:ipn_track_id])).empty?
      Paypal.verify(params)
      user = User.where(token_for_paypal: params[:cm])

      # REVIEW: Change this if we're not processing more types here
      case params[:txn_type]
        when 'subscr_signup'
          new_plan = Plan.find_from_payment(params[:mc_currency], params[:mc_amount3])
          user.update_from_paypal_signup(params, new_plan) unless new_plan.nil?
      end
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
