class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  before_filter :add_home_breadcrumb
  before_filter :get_promoted_notes
  before_filter :get_sections
  before_filter :set_public_cache_headers, only: [:index, :show, :show_channel]

  skip_before_filter :get_promoted_notes, :get_sections, if: proc { |_c| request.xhr? && request.path != '/' }

  def set_locale
    I18n.locale = params[:locale] || NB.locale || I18n.default_locale
  end

  def add_home_breadcrumb
    add_breadcrumb I18n.t('home.title'), :root_path
  end

  def get_promoted_notes
    @promoted_notes = Note.publishable.listable.blurbable.promotable
  end

  def get_sections
    @sections = Note.sections
  end

  def after_sign_up_path_for(_resource)
    user_event_path('signed_up')
  end

  def after_inactive_sign_up_path_for(_resource)
    user_event_path('signed_up_inactive')
  end

  def after_sign_in_path_for(_resource)
    user_event_path('signed_in')
  end

  def after_sign_out_path_for(_resource)
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

  def note_tags(note)
    @tags = note.tags.to_a.keep_if { |tag| Note.publishable.tagged_with(tag).size >= NB.tags_minimum.to_i }
  end

  def note_map(note)
    @map = mapify(note) if note.has_instruction?('map') && !note.inferred_latitude.nil?
  end

  def note_source(note)
    @source = Note.where(title: note.title).where.not(lang: note.lang).first if note.has_instruction?('parallel')
  end

  def set_public_cache_headers
    expires_in NB.cache_minutes.to_i.minutes, public: true
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_path, alert: exception.message
  end
end
