class ApplicationController < ActionController::Base

  protect_from_forgery

  add_breadcrumb I18n.t('home.title'), :root_path

end
