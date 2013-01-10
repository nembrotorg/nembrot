class CloudServicesController < ApplicationController

  def auth_callback
    cloud_service = CloudService.where( :name => params[:provider] ).first_or_initialize
    cloud_service.auth = request.env['omniauth.auth']
    cloud_service.save

file_name = File.join(Rails.root, 'spec', 'webmocks', 'evernote_omniauth_auth.json')
File.open(file_name, 'w') { |f| f.puts request.env['omniauth.auth'].to_json }

    flash[:success] = I18n.t('auth.success', :provider => params[:provider].titlecase)
    redirect_to '/'
  end

  def auth_failure
    flash[:error] = I18n.t('auth.failure', :provider => params[:provider].titlecase)
    flash[:error_details] = params[:message]
    redirect_to '/'
  end
end
