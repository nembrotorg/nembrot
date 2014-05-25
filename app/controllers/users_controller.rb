# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_action :validate_authorization_for_user, only: [:edit, :update]

  skip_before_filter :verify_authenticity_token, only: [:process_paypal_ipn]

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def process_paypal_pdt
    message_type, message = Paypal.new.process_pdt(params)
    flash[message_type] = message
    redirect_to home_url
  end

  def cancel_upgrade
    PAY_LOG.info "User #{ user.id } upgrade cancelled by user at PayPal site." # TODO: Add Google Analytics
    flash[:error] = 'Your upgrade was cancelled.'
    redirect_to home_url
  end

  def process_paypal_ipn
    Paypal.new.process_ipn(params)
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
    redirect_to home_url unless @user == current_user
  end
end
