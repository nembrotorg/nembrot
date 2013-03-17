class TagsController < ApplicationController

  add_breadcrumb I18n.t('tags.title'), :tags_path

  def index
    if Settings.tags.index.style == 'cloud'
      @tags = Note.publishable.tag_counts_on(:tags)
    else
      @tags = Note.publishable.tag_counts
    end

    respond_to do |format|
      format.html
      format.json { render :json => @tags }
    end
  end

  def show
    @tag = Tag.find_by_slug(params[:slug])
    @notes = Note.publishable.tagged_with(@tag.name)

    if Settings.tags.index.style == 'cloud'
      @tags = Note.publishable.tag_counts_on(:tags)
    else
      @tags = Note.publishable.tag_counts
    end

    add_breadcrumb @tag.name, tag_path(params[:slug])

    respond_to do |format|
      format.html
      format.json { render :json => @notes }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Tag: #{ params[:slug] } does not exist."
      redirect_to tags_path
  end
end
