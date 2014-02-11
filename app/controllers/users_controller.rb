# See http://www.codebeerstartups.com/2013/10/social-login-integration-with-all-the-popular-social-networks-in-ruby-on-rails/

class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update]
  before_filter :validate_authorization_for_user, only: [:edit, :update]

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def menu
    @channles_owned_by_current_user = Channel.where(user: current_user).pluck(:slug) if user_signed_in? 
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
