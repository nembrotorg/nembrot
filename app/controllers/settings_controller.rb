class SettingsController < ApplicationController

  load_and_authorize_resource

  def index
    @settings = Setting.all

    respond_to do |format|
      format.js
    end
  end

  def edit
    @channel_settings = Setting.all('channel.')
    @advanced_settings = Setting.all('advanced.')
    @style_settings = Setting.all('style.')

    add_breadcrumb I18n.t('settings.edit.title'), edit_settings_path
  end

  def update
    add_breadcrumb I18n.t('settings.edit.title'), edit_settings_path

    params[:settings].map do |key, value|
      Setting[key] = value
    end

    flash[:success] = I18n.t('settings.edit.success')
    # flash[:error] = I18n.t('settings.edit.failure')
    # render :edit
    redirect_to edit_settings_path
  end

  def reset
    Setting.reset(params[:namespace])
    flash[:success] = I18n.t("settings.reset.success_#{ params[:namespace] }", namespace: params[:namespace])
    redirect_to edit_settings_path
  end

  private

  def edited_params
    params.require(:settings)
  end
end
