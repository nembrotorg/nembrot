class HomeController < ApplicationController
  def index
    @all_interrelated_notes = Note.interrelated.publishable

    respond_to do |format|
      format.html
      format.json { render :json => @notes }
    end
  end
end
