class ChannelsController < ApplicationController

  # REVIEW: This is not secure
  # See http://factore.ca/on-the-floor/258-rails-4-strong-parameters-and-cancan
  load_and_authorize_resource except: :create
  skip_authorize_resource only: :create

  # before_action :set_channel_defaults, only: [:index, :show, :new, :edit, :update, :destroy]
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  before_action :fetch_evernote_notebooks, only: [:new, :edit]

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
    user_related_settings
    @channels = current_user.channels.order('slug')
    @paypal_transaction_token = current_user.token_for_paypal
  end

  def show
    redirect_to home_url(params[:id])
  end

  def new
    user_related_settings
    @channel = Channel.new
    @paypal_transaction_token = current_user.token_for_paypal unless current_user.nil?
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
      redirect_to edit_channel_url(@channel), notice: '<span id="channel-created">Channel created! Now choose a theme...</span>'
    else
      render action: 'new'
    end
  end

  def update
    if @channel.update(channel_params)
      redirect_to channels_url, notice: '<span id="channel-updated">Your website has been updated.</span>'
    else
      render action: 'edit'
    end
  end

  def destroy
    @channel.destroy
    redirect_to root_url, notice: 'Your website has been deleted.'
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
    params.require(:channel).permit(:name, :notebooks, :theme_id, :always_reset_on_create, :bibliography, :contact_email, :disqus_shortname, :facebook_app_id, :follow_on_facebook, :follow_on_soundcloud, :follow_on_tumblr, :follow_on_twitter, :follow_on_vimeo, :follow_on_youtube, :google_analytics_key, :index_on_google, :links_section, :locale, :only_show_notes_in_locale, :private, :promote, :show_nembrot_link, :url, :versions, :comments, :active, :breadcrumbs, :menu_at_top, :menu_at_bottom, :follow_on_googleplus, :newsletter, :promoted, :tags, :locale_auto, :copyright)
  end

  def user_related_settings
    @country = request.location.country_code unless request.location.blank?
    if @country.blank? || @country == 'RD'
      @country = 'US'
      @country_in_eu = false
    else
      @country_in_eu = Country.new(@country).in_eu?
    end
    @plan = current_user.nil? ? Plan.free : current_user.plan
    @themes = user_signed_in? && current_user.admin? ? Theme.all : Theme.public
  end

  def set_public_cache_headers
    expires_in 0.minutes, public: false
  end
end
