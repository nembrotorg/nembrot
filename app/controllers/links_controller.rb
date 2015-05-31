class LinksController < ApplicationController
  add_breadcrumb I18n.t('links.index.title'), :links_path

  def index
    page_number = params[:page] ||= 1
    all_links = Note.publishable.link

    page_size = Setting['advanced.notes_index_per_page'].to_i * 10
    @links = all_links.page(page_number).per(page_size).load
    @total_count = all_links.size
    @domains_count = all_links.pluck(:url_domain).uniq.size

    respond_to do |format|
      format.html
      format.atom { render atom: all_links }
      format.json { render json: all_links }
    end
  end
end
