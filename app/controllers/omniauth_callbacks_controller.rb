class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_filter :authenticate_user!

  def all
    p env['omniauth.auth']
    user = User.from_omniauth(env['omniauth.auth'], current_user)
    if user.persisted?
      flash[:notice] = t('devise.sessions.oauth.signed_in', provider: env['omniauth.auth'].provider.to_s.titleize)
      user.remember_me!
      sign_in_and_redirect user
    else
      session['devise.user_attributes'] = user.attributes
      redirect_to new_user_registration_url
    end
  end

  def failure
    # handle you logic here..
    # and delegate to super.
    super
  end

  alias_method :evernote, :all
  alias_method :facebook, :all
  alias_method :github, :all
  alias_method :google_oauth2, :all
  alias_method :gplus, :all
  alias_method :linkedin, :all
  alias_method :passthru, :all
  alias_method :twitter, :all
end
