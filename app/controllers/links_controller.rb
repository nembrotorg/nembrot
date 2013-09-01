# encoding: utf-8

class LinksController < ApplicationController

  load_and_authorize_resource

  add_breadcrumb I18n.t('links.index.title'), :links_path

  def admin
    @links = Link.publishable

    add_breadcrumb I18n.t('links.admin.title_short'), links_admin_path

    respond_to do |format|
      format.html
      format.json { render json: @books }
    end
  end

  def edit
    @link = Link.find params[:id]

    add_breadcrumb I18n.t('links.admin.title_short'), links_admin_path
    add_breadcrumb @link.channel, edit_link_path(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def index
    @channels = Link.publishable.select('DISTINCT channel').group(:channel).count
    @links_count = Link.publishable.size

    respond_to do |format|
      format.html
      format.json { render json: @books }
    end
  end

  def show_channel
    @links_channel = Link.publishable.where(channel: params[:slug])
    @channel = @links_channel.first.channel
    @name = @links_channel.first.name

    add_breadcrumb @channel, link_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render json: @links_channel }
    end
    rescue
      flash[:error] = t('links.show_channel.not_found', channel: params[:slug])
      redirect_to links_path
  end

  def update
    @link = Link.find_by_id(params[:id])
   
    add_breadcrumb I18n.t('links.admin.title_short'), links_admin_path
    add_breadcrumb @link.channel, edit_link_path(params[:id])

    if @link.update_attributes(link_params)
      flash[:success] = I18n.t('links.edit.success', channel: @link.channel)
      redirect_to links_admin_path
    else
      flash[:error] = I18n.t('links.edit.failure')
      render :edit
    end
  end

  private

  def link_params
    params.require(:link).permit(:altitude, :attempts, :author, :canonical_url, :channel, :dirty, :domain, :error, 
                                 :lang, :latitude, :longitude, :modified, :name, :paywall, :protocol, :publisher, 
                                 :title, :url, :website_name) 
  end

end
