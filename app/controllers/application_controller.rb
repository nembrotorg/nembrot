class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || Settings.locale || I18n.default_locale

    # Strange place for this but otherwise 'home' translation is not read.
    #  See http://stackoverflow.com/questions/10805196/ruby-on-rails-i18n-breadcumbs
    #  And: http://stackoverflow.com/questions/10865962/rails-breadcrumb-and-i18n
    add_breadcrumb I18n.t('home.title'), :root_path
  end

  rescue_from CanCan::AccessDenied do |exception| 
    redirect_to new_user_session_path, :alert => exception.message
  end

end
