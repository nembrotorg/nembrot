class LinksController < ApplicationController
  add_breadcrumb I18n.t('links.index.title'), :links_path

  def index
    page_number = params[:page] ||= 1
    all_links = Note.publishable.link

    @links = all_links.page(page_number).load
    @total_count = all_links.size
    @domains_count = all_links.map { |link| link.inferred_url_domain unless link.inferred_url_domain.nil? } .uniq.size

    respond_to do |format|
      format.html
      format.atom { render atom: all_links }
      format.json { render json: all_links }
    end
  end
end
