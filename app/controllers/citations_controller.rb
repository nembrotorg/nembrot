# encoding: utf-8

class CitationsController < ApplicationController
  add_breadcrumb I18n.t('citations.index.title'), :citations_path

  def index
    page_number = params[:page] ||= 1
    all_citations = Note.citation.publishable

    @citations = all_citations.page(page_number).per(NB.citations_index_per_page.to_i).load
    @total_count = all_citations.size
    @books_count = all_citations.map { |citation| citation.books unless citation.books.blank? } .uniq.size
    @domains_count = all_citations.map { |link| link.inferred_url_domain unless link.inferred_url_domain.nil? } .uniq.size
  end

  def show
    @citation = Note.citation.publishable.find(params[:id])
    @tags = @citation.tags

    add_breadcrumb I18n.t('citations.show.title', id: @citation.id), citation_path(@citation)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = I18n.t('citations.show.not_found', id: params[:id])
      redirect_to citations_path
  end
end
