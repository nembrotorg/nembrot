class NotesController < ApplicationController

  add_breadcrumb I18n.t('notes.title'), :notes_path

  def index

    @notes = Note.find(:all)

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @note = Note.find(params[:id])
    @tags = @note.tags

    add_breadcrumb I18n.t('notes.short', :id => @note.id), note_path(@note)

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

  def version
    @note = Note.find(params[:id])
    @diffed_version = @note.diffed_version(params[:sequence].to_i)

    add_breadcrumb I18n.t('notes.short', :id => @note.id), note_path(@note)
    add_breadcrumb I18n.t('notes.versions.short', :sequence => @diffed_version.sequence), note_version_path(@note, @diffed_version.sequence)

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

  def update_cloud

    @guid = params[:guid]

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end
end
