class LinksController < ApplicationController
  add_breadcrumb I18n.t('links.index.title'), :links_path

  def index
    page_number = params[:page] ||= 1
    all_links = Note.link.publishable

    page_size = NB.notes_index_per_page.to_i * 10
    @links = all_links.page(page_number).per(page_size).load
    @total_count = all_links.size
    @domains_count = all_links.pluck(:url_domain).uniq.size
  end
end
