class NotesController < ApplicationController

  def index
    @notes = NoteVersion.current

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @versions = Note.find(params[:id])
    @note = @versions.note_versions.last
    @tags = @note.tags

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

end
