class FeaturesController < ApplicationController

  def show
    @notes = Note.channelled(@current_channel).publishable.where(feature: params[:feature], lang: @current_channel.locale)

    if @notes.empty?
      flash[:error] = "404 error! #{ request.url } does not exist."
      redirect_to "/#{@current_channel.slug}"
    elsif @notes.listable.size > 1 && params[:feature_id].nil? && @notes.where(feature_id: nil).blank?
      show_feature_index
    elsif @notes.listable.size > 1 && params[:feature_id].nil?
      show_note_feature_index
    else
      show_feature
    end
  end

  private

  def show_note_feature_index
    page_number = params[:page] ||= 1
    @notes = @notes.page(page_number).load # Not using listable
    @title = @notes.first.main_title

    @note = @notes.where(feature_id: nil).first
    @notes = @notes.where.not(feature_id: nil)

    note_tags(@note)
    commontator_thread_show(@note)
    interrelated_notes_features_and_citations
    @map = mapify(@note) if @note.has_instruction?('map') && !@note.inferred_latitude.nil?
    @source = Note.where(title: @note.title).where.not(lang: @note.lang).first if @note.has_instruction?('parallel')

    @total_count = @notes.size
    @word_count = @notes.sum(:word_count)
    @special_css_instructions = 'ins-features-index'
    add_breadcrumb @notes.first.get_feature_name, feature_path(@notes.first.feature)

    @promoted_notes = @notes
    render template: 'notes/show'
  end

  def show_feature_index
    page_number = params[:page] ||= 1
    @notes = @notes.listable.page(page_number).load
    @title = @notes.first.main_title
    interrelated_notes_features_and_citations
    @map = @notes.mappable
    @total_count = @notes.size
    @word_count = @notes.sum(:word_count)
    @special_css_instructions = 'ins-features-index'
    add_breadcrumb @notes.first.get_feature_name, feature_path(@notes.first.feature)
    render template: 'notes/index'
  end

  def show_feature
    @note = params[:feature_id].nil? ? @notes.first : @notes.where(feature_id: params[:feature_id]).first
    note_tags(@note)
    commontator_thread_show(@note)
    interrelated_notes_features_and_citations
    @map = mapify(@note) if @note.has_instruction?('map') && !@note.inferred_latitude.nil?
    @source = Note.where(title: @note.title).where.not(lang: @note.lang).first if @note.has_instruction?('parallel')
    add_breadcrumb @note.get_feature_name, feature_path(@note.feature)
    add_breadcrumb @note.get_feature_id, feature_path(@note.feature, @note.feature_id) unless params[:feature_id].nil?

    # REVIEW: These are declared twice!
    # get_promoted_notes(@note)
    @promoted_notes = @notes.where.not(id: @note.id)

    # If there are no more notes in this feature, load notes index
    @promoted_notes = Note.channelled(@current_channel)
                          .publishable.where(lang: @current_channel.locale)
                          .where.not(id: @note.id)
                          .page(1) if @promoted_notes.empty?

    render template: 'notes/show'
  end

  def default_url_options
    return { channel: @current_channel.nil? ? 'default' : @current_channel.slug }
  end
end
