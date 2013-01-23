class ApplicationController < ActionController::Base

  protect_from_forgery

  add_breadcrumb I18n.t('home.title'), :root_path

  before_filter :set_locale
   
  def set_locale
    I18n.locale = params[:locale] || Settings.locale
  end
end
