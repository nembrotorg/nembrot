class NotesController < ApplicationController

  def index
    @notes = Note.find(:all)

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @versions = Note.find(params[:id])
    @note = @versions.note_versions.last

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

end
