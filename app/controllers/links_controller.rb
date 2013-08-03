# encoding: utf-8

class LinksController < ApplicationController

  add_breadcrumb I18n.t('links.index.title'), :links_path

  def index
    # REVIEW: This gives the count of links per channel, what we really want is number of citations
    # @channels = Link.publishable.group(:channel).count(:channel)
    @channels = Link.publishable.group(:channel)

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
end
