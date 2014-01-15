class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]

  add_breadcrumb I18n.t('channels.index.title'), :channels_path

  def index
    @channels = current_user.channels
  end

  def show
  end

  def new
    @channel = Channel.new
    @evernote_notebooks_list = user_signed_in? ? EvernoteNotebookList.new(current_user).array : []

    add_breadcrumb I18n.t('.title'), :new_channel_path
  end

  def edit
    @evernote_notebooks_list = user_signed_in? ? EvernoteNotebookList.new(current_user).array : []

    add_breadcrumb I18n.t('.title'), :edit_channel_path
  end

  def create
    @channel = current_user.channels.new(channel_params)

    if @channel.save
      redirect_to channels_path, notice: 'Channel was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @channel.update(channel_params)
      redirect_to channels_path, notice: 'Channel was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @channel.destroy
    redirect_to channels_path, notice: 'Channel was successfully destroyed.'
  end

  private

  def set_channel
    @channel = current_user.channels.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(:name, :theme, :notebooks, :id)
  end
end
