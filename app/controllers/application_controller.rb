class ApplicationController < ActionController::Base

  layout proc{|c| c.request.xhr? ? false : 'application' }

  protect_from_forgery

  # REVIEW: only use before filters for locale and cache headers. Otherwise we can't use page-caching
  before_action :set_locale
  before_action :add_home_breadcrumb, only: [:index, :show, :map, :new, :edit, :admin]
  before_action :get_promoted_notes, only: [:index, :show, :map, :new, :edit, :admin]
  before_action :get_sections, only: [:index, :show, :map, :new, :edit, :admin]
  before_action :get_map_all_markers, only: [:index, :show, :map]
  before_action :set_public_cache_headers, only: [:index, :show, :map]

  skip_before_action :get_promoted_notes, if: proc { |c| request.xhr? }

  def set_locale
    I18n.locale = params[:locale] || Setting['advanced.locale'] || I18n.default_locale
  end

  def add_home_breadcrumb
    add_breadcrumb t('site.title')
  end

  def get_promoted_notes(exclude_note = nil)
    # REVIEW: If promotable did not return an array this could be simpler
    @promoted_notes = Note.publishable.listable.blurbable
    @promoted_notes = @promoted_notes.where.not(id: exclude_note.id) unless exclude_note.nil?
    @promoted_notes = @promoted_notes.promotable
    # This injects default note into the list when channel has one note (which is excluded)
    # @promoted_notes = @default_notes if @promoted_notes.empty?
    @promoted_notes
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
    # user_event_path('signed_in')
    root_path
  end

  def after_sign_out_path_for(resource)
    # user_event_path('signed_out')
    root_path
  end

  def get_map_all_markers
    all_mappable_notes = Note.publishable.listable.blurbable.mappable
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
    @all_interrelated_notes_and_features = Note.interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.interrelated.publishable.citations
  end

  def note_tags(note)
    @tags = note.tags.to_a.keep_if { |tag| Note.publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }
  end

  def note_source(note)
    @source = Note.where(title: note.title).where.not(lang: note.lang).first if note.has_instruction?('parallel')
  end

  def set_public_cache_headers
    expires_in Constant.uncache_channel_minutes.minutes
  end

  rescue_from CanCan::AccessDenied do |exception|
    # redirect_to root_path, alert: exception.message
    redirect_to root_path, alert: exception.message
  end
end
