class SettingsController < ApplicationController
  load_and_authorize_resource

  def index
    @settings = ENV.select { |var| !var.match(/.*secret.*/) }

    respond_to do |format|
      format.js
    end
  end

  def edit
    @settings = ENV.select { |var| !var.match(/.*secret.*/) }

    add_breadcrumb I18n.t('settings.edit.title'), edit_settings_path
  end

  def update
    add_breadcrumb I18n.t('settings.edit.title'), edit_settings_path

    params[:settings].map do |key, value|
      ENV[key] = value.to_s
    end

    flash[:success] = I18n.t('settings.edit.success')
    # flash[:error] = I18n.t('settings.edit.failure')
    # render :edit
    redirect_to edit_settings_path
  end

  private

  def edited_params
    params.require(:settings)
  end
end
