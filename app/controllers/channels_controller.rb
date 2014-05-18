class ChannelsController < ApplicationController

  # REVIEW: This is not secure
  # See http://factore.ca/on-the-floor/258-rails-4-strong-parameters-and-cancan
  load_and_authorize_resource except: :create
  skip_authorize_resource only: :create

  before_action :set_channel_defaults, only: [:index, :show, :new, :edit, :update, :destroy]
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  before_action :fetch_evernote_notebooks, only: [:show, :new, :edit, :update, :destroy]

  skip_before_action :get_map_all_markers

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
    @channels = current_user.channels.order('slug')
    @paypal_transaction_token = current_user.token_for_paypal
  end

  def show
    redirect_to home_url(params[:id])
  end

  def new
    user_related_settings
    @channel = Channel.new
    @paypal_transaction_token = current_user.token_for_paypal unless current.user.nil?
    add_breadcrumb I18n.t('channels.new.title'), :new_channel_path
  end

  def edit
    user_related_settings
    @plan = current_user.nil? ? Plan.free : current_user.plan
    @paypal_transaction_token = current_user.token_for_paypal
    add_breadcrumb I18n.t('channels.edit.title'), :edit_channel_path
  end

  def create
    @channel = current_user.channels.new(channel_params)
    @paypal_transaction_token = current_user.token_for_paypal

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
    params.require(:channel).permit(:name, :notebooks, :theme_id)
  end

  def user_related_settings
    @country = request.location.country_code
    @country_in_eu = @country == 'RD' ? false : Country.new(@country).in_eu?
    @plan = current_user.nil? ? Plan.free : current_user.plan
    @themes = user_signed_in? && current_user.admin? ? Theme.all : Theme.public
  end

  def set_public_cache_headers
    expires_in 0.minutes, public: false
  end
end
