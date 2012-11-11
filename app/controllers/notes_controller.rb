class NotesController < ApplicationController

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

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

  def version
    @note = Note.find(params[:id])
    @diffed_version = @note.diffed_version(params[:sequence].to_i)

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end
end
