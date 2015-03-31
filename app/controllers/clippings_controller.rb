class ClippingsController < ApplicationController

  add_breadcrumb I18n.t('clippings.index.title'), :notes_path

  def index
    page_number = params[:page] ||= 1
    all_clippings = Note.publishable.clipping

    @clippings = all_clippings.page(page_number).load
    @total_count = all_clippings.size

    respond_to do |format|
      format.html
      format.atom { render atom: all_clippings }
      format.json { render json: all_clippings }
    end
  end
end
