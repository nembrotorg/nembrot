# encoding: utf-8

class CitationsController < ApplicationController

  add_breadcrumb I18n.t('citations.index.title'), :citations_path

  def index

    page_number = params[:page] ||= 1
    all_citations = Note.publishable.citations

    @citations = all_citations.page(page_number).per(Setting['advanced.citations_index_per_page'].to_i).load
    @total_count = all_citations.size
    @books_count = all_citations.keep_if { |citation| !citation.books.nil? } .size
    @links_count = all_citations.keep_if { |citation| !citation.links.nil? } .size

    respond_to do |format|
      format.html
      format.json { render json: @citations }
    end
  end

  def show
    @citation = Note.publishable.citations.find(params[:id])
    @tags = @citation.tags

    add_breadcrumb I18n.t('citations.show.title', :id => @citation.id), citation_path(@citation)

    respond_to do |format|
      format.html
      format.json { render :json => @citation }
    end

    rescue ActiveRecord::RecordNotFound
      flash[:error] = I18n.t('citations.show.not_found', id: params[:id])
      redirect_to citations_path
  end

end
