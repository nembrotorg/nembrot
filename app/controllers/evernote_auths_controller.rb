class EvernoteAuthsController < ApplicationController

  def auth_callback
    evernote_auth = EvernoteAuth.first_or_initialize
    evernote_auth.auth = request.env['omniauth.auth']
    evernote_auth.save!

    flash[:success] = I18n.t('auth.success', :provider => 'Evernote')
    redirect_to '/'
  end

  def auth_failure
    flash[:error] = I18n.t('auth.failure', :provider => 'Evernote')
    flash[:error_details] = params[:message]
    redirect_to '/'
  end
end
