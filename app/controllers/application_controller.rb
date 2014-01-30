class ApplicationController < ActionController::Base

  layout proc{|c| c.request.xhr? ? false : 'application' }

  protect_from_forgery

  # REVIEW: only use before filters for locale and cache headers. Otherwise we can't use page-chaching
  before_filter :set_locale
  before_filter :set_channel_defaults, only: [:index, :show, :choose, :new, :edit, :admin, :show_channel]
  before_filter :add_home_breadcrumb, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :get_promoted_notes, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :get_sections, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :set_public_cache_headers, only: [:index, :show, :show_channel]

  skip_before_filter :get_promoted_notes, :get_sections, if: proc { |c| request.xhr? }

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
    @current_channel = Channel.where('slug = ?', params[:channel] || 'default').first
    @current_user_owns_current_channel = user_signed_in? && @current_channel.user_id == current_user.id
    @channels_owned_by_nembrot = Channel.owned_by_nembrot
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
    @promoted_notes = @default_notes if @promoted_notes.empty?
    @promoted_notes
  end

  def get_sections
    @sections = Note.channelled(@current_channel).sections
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

  def mapify(notes)
    @map = Gmaps4rails.build_markers(notes) do |note, marker|
      marker.lat note.inferred_latitude
      marker.lng note.inferred_longitude
      marker.infowindow render_to_string(partial: '/notes/maps_infowindow', locals: { note: note })
      marker.title note.headline
    end
  end

  def interrelated_notes_features_and_citations
    @all_interrelated_notes_and_features = Note.channelled(@current_channel).interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.channelled(@current_channel).interrelated.publishable.citations
  end

  def note_tags(note)
    @tags = note.tags.keep_if { |tag| Note.channelled(@current_channel).publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }
  end

  def note_map(note)
    @map = mapify(note) if note.has_instruction?('map') && !note.inferred_latitude.nil?
  end

  def note_source(note)
    @source = Note.where(title: note.title).where.not(lang: note.lang).first if note.has_instruction?('parallel')
  end

  def set_public_cache_headers
    # If we're using a channel owned by current_user, we set this to 0
    expires_in Constant.cache_minutes.minutes, public: Constant.cache_minutes != 0
  end

  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to root_path, alert: exception.message
    redirect_to root_path, alert: exception.message
  end
end
