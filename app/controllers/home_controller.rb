class HomeController < ApplicationController
  def index
    @all_interrelated_notes_and_features = Note.interrelated.publishable.notes_and_features
    @all_interrelated_citations = Note.interrelated.publishable.citations

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def default_url_options
    return { channel: @current_channel.nil? ? 'default' : @current_channel.slug }
  end
end
