class HomeController < ApplicationController
  def index
    @notes = Note.tagged_with(Settings.home.instructions.required, :on => :instructions)

    respond_to do |format|
      format.html
      format.json { render :json => @notes }
    end
  end
end
