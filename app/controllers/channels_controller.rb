class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  before_action :fetch_evernote_notebooks

#  skip_before_filter :set_current_channel, :add_home_breadcrumb, :get_promoted_notes, :get_sections

  add_breadcrumb I18n.t('channels.index.title'), :channels_path

  def choose
    # Use this when loading dashboard
    if @current_user_owns_current_channel
      redirect_to edit_channel_url(@current_channel)
    elsif current_user.nil? || current_user.channels.empty?
      redirect_to new_channel_url
    else
      redirect_to channels_url
    end
  end

  def index
    @channels = current_user.channels
  end

  def show
    redirect_to home_url(params[:id])
  end

  def new
    @channel = Channel.new
    add_breadcrumb I18n.t('channels.new.title'), :new_channel_path
  end

  def edit
    add_breadcrumb I18n.t('channels.edit.title'), :edit_channel_path
  end

  def create
    @channel = current_user.channels.new(channel_params)

    if @channel.save
      redirect_to edit_channel_url(@channel), notice: 'Channel created! Now choose a theme...'
    else
      render action: 'new'
    end
  end

  def update
    if @channel.update(channel_params)
      redirect_to channels_url, notice: 'Channel was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @channel.destroy
    redirect_to channels_url, notice: 'Channel was successfully deleted.'
  end

  def available
    @name_candidate = params[:name]
    forbidden_names = %w(default help faqs nembrot cunt pussy) #REVIEW: Put in settings
    @available = Channel.where(slug: @name_candidate.parameterize).size == 0 && !forbidden_names.include?(@name_candidate)
    render partial: 'channels/available'
  end

  private

  def set_channel
    @channel = current_user.channels.find(params[:id])
  end

  def fetch_evernote_notebooks
    # REVIEW: Cache this
    # Check not only that user is signed in, but that she is connected to evernote
    @evernote_notebooks_list = user_signed_in? ? EvernoteNotebookList.new(current_user).array : []
  end

  def channel_params
    params.require(:channel).permit(:name, :theme, :notebooks, :id)
  end

  def set_public_cache_headers
    expires_in 0.minutes, public: false
  end
end
