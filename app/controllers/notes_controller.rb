class NotesController < ApplicationController

  add_breadcrumb I18n.t('notes.index.title'), :notes_path

  def index
    @notes = Note.publishable.listable.blurbable.load
    @word_count = @notes.sum(:word_count)
    @map = @notes.to_gmaps4rails

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def map
    @notes = Note.publishable.listable.load
    @word_count = @notes.sum(:word_count)

    @map = @notes.to_gmaps4rails do |note, marker|
      marker.infowindow render_to_string(partial: '/notes/maps_infowindow', locals: { note: note})
      marker.title note.title
    end

    add_breadcrumb I18n.t('notes.map.title'), notes_path

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @note = Note.publishable.find(params[:id])
    @tags = @note.tags
    @map_notes = @note.to_gmaps4rails
    @map_images = @note.resources.to_gmaps4rails

    @map = (JSON.parse(@map_notes) + JSON.parse(@map_images)).to_json # REVIEW

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)
    # add_breadcrumb I18n.t('notes.versions.show.title', sequence: @note.versions.size),
    # note_version_path(@note, @note.versions.size)

    respond_to do |format|
      format.html
      format.json { render json: @note }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
  end

  def version
    @note = Note.publishable.find(params[:id])
    @diffed_version = DiffedNoteVersion.new(@note, params[:sequence].to_i)
    @diffed_tag_list = DiffedNoteTagList.new(@diffed_version.previous_tag_list, @diffed_version.tag_list).list

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)
    add_breadcrumb I18n.t('notes.version.title', sequence: @diffed_version.sequence), note_version_path(@note, @diffed_version.sequence)

    respond_to do |format|
      format.html
      format.json { render json: @diffed_version }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
    rescue
      flash[:error] = t('notes.version.not_found', id: params[:id], sequence: params[:sequence])
      redirect_to note_path(@note)
  end
end
