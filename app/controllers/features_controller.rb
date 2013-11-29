class FeaturesController < ApplicationController

  def show
    @notes = Note.where(feature: params[:feature])

    if @notes.empty?
      flash[:error] = "404 error! #{ request.url } does not exist."
      redirect_to root_path
    elsif @notes.size > 1 && params[:feature_id].nil?
      page_number = params[:page] ||= 1
      @notes = @notes.page(page_number).load
      @title = @notes.first.main_title
      @map = @notes.mappable
      @total_count = @notes.size
      @word_count = @notes.sum(:word_count)
      add_breadcrumb @notes.first.feature, feature_path(@notes.first.feature)
      render template: 'notes/index'
    else
      @note = params[:feature_id].nil? ? @notes.first : @notes.where(feature_id: params[:feature_id]).first
      @tags = @note.tags.keep_if { |tag| Note.publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }
      commontator_thread_show(@note)
      @map = mapify(@note) if @note.has_instruction?('map') && !@note.inferred_latitude.nil?
      add_breadcrumb @note.feature, feature_path(@note.feature)
      add_breadcrumb params[:feature_id], feature_path(@note.feature, @note.feature_id) unless params[:feature_id].nil?
      render template: 'notes/show'
    end
  end
end
