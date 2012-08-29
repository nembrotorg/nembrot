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
    @note = @versions
    @tags = @note.tags

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

end
