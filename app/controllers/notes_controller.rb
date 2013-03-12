class NotesController < ApplicationController

  include ActionView::Helpers::SanitizeHelper

  add_breadcrumb I18n.t('notes.title'), :notes_path

  def index

    @notes = Note.active.all

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @note = Note.active.find(params[:id])
    @tags = @note.tags

    add_breadcrumb I18n.t('notes.short', :id => @note.id), note_path(@note)

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Note #{ params[:id] } is not available."
      redirect_to notes_path
  end

  def version
    @note = Note.active.find(params[:id])
    @diffed_version = @note.diffed_version(params[:sequence].to_i)

    add_breadcrumb I18n.t('notes.short', :id => @note.id), note_path(@note)
    add_breadcrumb I18n.t('notes.versions.short', :sequence => @diffed_version.sequence), note_version_path(@note, @diffed_version.sequence)

    respond_to do |format|
      format.html
      format.json { render :json => @diffed_version }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Note #{ params[:id] } v#{ params[:sequence] } is not available."
      redirect_to note_path(@note)
  end
end
