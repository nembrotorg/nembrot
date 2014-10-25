class ApplicationController < ActionController::Base

  layout proc{|c| c.request.xhr? ? false : 'application' }

  protect_from_forgery

  # REVIEW: only use before filters for locale and cache headers. Otherwise we can't use page-caching
  before_action :set_locale
  before_action :set_channel_defaults, only: [:index, :show, :map, :choose, :new, :edit, :admin, :show_channel]
  before_action :set_current_channel, only: [:index, :show, :map, :choose, :new, :edit, :admin, :show_channel]
  before_action :add_home_breadcrumb, only: [:index, :show, :map, :new, :edit, :admin, :show_channel]
  before_action :get_promoted_notes, only: [:index, :show, :map, :new, :edit, :admin, :show_channel]
  before_action :get_sections, only: [:index, :show, :map, :new, :edit, :admin, :show_channel]
  before_action :get_map_all_markers, only: [:index, :show, :map, :show_channel]
  before_action :set_public_cache_headers, only: [:index, :show, :show_channel, :map]

  skip_before_action :get_promoted_notes, :get_sections, if: proc { |c| request.xhr? }

  def set_locale
    I18n.locale = params[:locale] || Setting['advanced.locale'] || I18n.default_locale
  end

  def set_channel_defaults
    # Default user (a registered user with the same name as the one in secret.yml)
    #  needs to have a notebook called 'default'. It should have at least one __HOME
    #  and one __DEMO note.
    #  REVIEW: use Channel.friendly.find(); and shouldn't we just set 'default' as default for :channel in routes?
    @default_channel = Channel.where('slug = ?', 'default').first
    @default_notes = Note.channelled(@default_channel).with_instruction('demo')
    @default_note = @default_notes.first
    @channels_owned_by_nembrot = Channel.owned_by_nembrot
    @themes_for_js = Theme.hash_for_js
  rescue
    redirect_to home_url, notice: 'This website does not exist!'
  end

  def set_current_channel
    # REVIEW: Channel is here selected even if inactive
    @current_channel = Channel.where('slug = ?', params[:channel] || 'default').first

    # Set current channel to home unless current user is editing, and can set advanced settings
    if @current_channel.nil? && !(self.class.name == 'channels' && current_user.plan.advanced_settings == true)
      @current_channel = @default_channel
    end

    @current_user_owns_current_channel = user_signed_in? && @current_channel.user_id == current_user.id
    @home_note = Note.channelled(@current_channel).publishable.homeable.first

    @home_note = @default_note if @home_note.blank?

    @current_channel_author = @home_note.author.blank? ? 'anon' : @home_note.author

    # Add plan-specific css
    # HOTFIX for #15
    @current_channel_css_modules = ''
    @current_channel_css_modules += @current_channel.theme.css
    @current_channel_css_modules += ' hd-images-module' if @current_channel.user.plan.hd_images?
  end

  def add_home_breadcrumb
    add_breadcrumb I18n.t('home.title'), '/'
    add_breadcrumb @current_channel.name, home_path(@current_channel) unless @current_channel.name == 'default'
  end

  def get_promoted_notes(exclude_note = nil)
    # REVIEW: If promotable did not return an array this could be simpler
    @promoted_notes = Note.channelled(@current_channel).publishable.listable.blurbable
    @promoted_notes = @promoted_notes.where.not(id: exclude_note.id) unless exclude_note.nil?
    @promoted_notes = @promoted_notes.promotable
    # This injects default note into the list when channel has one note (which is excluded)
    # @promoted_notes = @default_notes if @promoted_notes.empty?
    @promoted_notes
  end

  def get_sections
    @sections = Note.where(lang: Setting['advanced.locale']).channelled(@current_channel).sections
  end

  def after_sign_up_path_for(resource)
    user_event_path('signed_up')
  end

  def after_inactive_sign_up_path_for(resource)
    user_event_path('signed_up_inactive')
  end

  def after_sign_in_path_for(resource)
    # user_event_path('signed_in')
    root_path
  end

  def after_sign_out_path_for(resource)
    # user_event_path('signed_out')
    root_path
  end

  def get_map_all_markers
    all_mappable_notes = Note.channelled(@current_channel).publishable.listable.blurbable.mappable
    @map_all_markers = mapify(all_mappable_notes)
  end

  def note_map(note)
    @map = mapify(note) if note.has_instruction?('map') && !note.inferred_latitude.nil?
  end

  def mapify(notes)
    markers = []
    Array(notes).each do |note|
      markers.push({
        'lat'       => note.inferred_latitude,
        'lng'       => note.inferred_longitude,
        'marker'    => "<a href=\"#{ note_path(note) }\" data-tags=\"#{ note.tag_list }\" title=\"#{ note.tag_list }\">#{ note.headline }</a>"
      })
    end
    markers
  end

  def interrelated_notes_features_and_citations
    @all_interrelated_notes_and_features = Note.channelled(@current_channel).interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.channelled(@current_channel).interrelated.publishable.citations
  end

  def note_tags(note)
    @tags = note.tags.keep_if { |tag| Note.channelled(@current_channel).publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }
  end

  def note_source(note)
    @source = Note.where(title: note.title).where.not(lang: note.lang).first if note.has_instruction?('parallel')
  end

  def set_public_cache_headers
    # If channel was updated recently, we do not cache
    # Also, if current channel is owned by current_user?
    cache_minutes = @current_channel.updated_at > Constant.uncache_channel_minutes.minutes.ago ? 0 : Constant.cache_minutes
    expires_in cache_minutes.minutes, public: cache_minutes != 0
  end

  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to root_path, alert: exception.message
    redirect_to root_path, alert: exception.message
  end
end
