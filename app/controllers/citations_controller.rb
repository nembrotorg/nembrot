# encoding: utf-8

class CitationsController < ApplicationController

  add_breadcrumb I18n.t('citations.index.title'), :citations_path

  def index

    @citations = Note.publishable.citations.all

    respond_to do |format|
      format.html
      format.json { render json: @citations }
    end
  end

  def show
    @citation = Note.publishable.citations.find(params[:id])
    @tags = @citation.tags

    add_breadcrumb I18n.t('citations.show.short', :id => @citation.id), citation_path(@citation)

    respond_to do |format|
      format.html
      format.json { render :json => @citation }
    end

    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Citation #{ params[:id] } is not available."
      redirect_to citations_path
  end

end
