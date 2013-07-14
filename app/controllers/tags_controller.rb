class TagsController < ApplicationController

  add_breadcrumb I18n.t('tags.index.title'), :tags_path

  def index

    # Do these need to be different?

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
    @notes = Note.publishable.listable.tagged_with(@tag.name)
    @citations = Note.publishable.citations.tagged_with(@tag.name)

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
    rescue
      flash[:error] = I18n.t('tags.show.not_found', slug: 'nonexistent')
      redirect_to tags_path
  end
end
