class ApplicationController < ActionController::Base

  layout proc{|c| c.request.xhr? ? false : 'application' }

  protect_from_forgery

  before_filter :set_locale
  before_filter :set_current_channel, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :add_home_breadcrumb, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :get_promoted_notes, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :get_sections, only: [:index, :show, :new, :edit, :admin, :show_channel]
  before_filter :set_public_cache_headers, only: [:index, :show, :show_channel]

  skip_before_filter :get_promoted_notes, :get_sections, if: proc { |c| request.xhr? }

  def set_locale
    I18n.locale = params[:locale] || Setting['advanced.locale'] || I18n.default_locale
  end

  def set_current_channel
    @current_channel = Channel.where('slug = ?', params[:channel]).first unless params[:channel].blank?
    @current_channel_theme = @current_channel.nil? ? 'default' : @current_channel.theme
    @current_channel_name = @current_channel.nil? ? 'default' : @current_channel.name
  end

  def add_home_breadcrumb
    add_breadcrumb I18n.t('home.title'), :root_path
    add_breadcrumb @current_channel_name, :notes_path
  end

  def get_promoted_notes
    @promoted_notes = Note.publishable.listable.blurbable.promotable
  end

  def get_sections
    @sections = Note.sections
  end

  def after_sign_up_path_for(resource)
    user_event_path('signed_up')
  end

  def after_inactive_sign_up_path_for(resource)
    user_event_path('signed_up_inactive')
  end

  def after_sign_in_path_for(resource)
    user_event_path('signed_in')
  end

  def after_sign_out_path_for(resource)
    user_event_path('signed_out')
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
    @all_interrelated_notes_and_features = Note.interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.interrelated.publishable.citations
  end

  def note_tags(note)
    @tags = note.tags.keep_if { |tag| Note.publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }
  end

  def note_map(note)
    @map = mapify(note) if note.has_instruction?('map') && !note.inferred_latitude.nil?
  end

  def note_source(note)
    @source = Note.where(title: note.title).where.not(lang: note.lang).first if note.has_instruction?('parallel')
  end

  def set_public_cache_headers
    expires_in Constant.cache_minutes.minutes, public: Constant.cache_minutes != 0
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, alert: exception.message
  end
end
