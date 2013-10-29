class TagsController < ApplicationController

  add_breadcrumb I18n.t('tags.index.title'), :tags_path

  def index

    @tags = Note.publishable.tag_counts_on(:tags)
    @references_count = @tags.to_a.sum { |t| t.count }

    respond_to do |format|
      format.html
      format.json { render :json => @tags }
    end
  end

  def show
    @tag = Tag.find_by_slug(params[:slug])
    @notes = Note.publishable.listable.blurbable.tagged_with(@tag.name)
    @citations = Note.publishable.citations.tagged_with(@tag.name)

    @word_count = @notes.sum(:word_count)
    @map = mapify(@notes.mappable)

    add_breadcrumb @tag.name, tag_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render :json => @notes }
    end
    rescue
     flash[:error] = I18n.t('tags.show.not_found', slug: 'nonexistent')
     redirect_to tags_path
  end

  def map
    @tag = Tag.find_by_slug(params[:slug])
    @notes = Note.publishable.listable.mappable.tagged_with(@tag.name)
    @word_count = @notes.sum(:word_count)

    @map = mapify(@notes.mappable)

    add_breadcrumb @tag.name, tag_path(params[:slug])
    add_breadcrumb I18n.t('map'), tag_map_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render :json => @tag }
    end
  end
end
