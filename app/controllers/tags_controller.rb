class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    # Can this be transferred to model?
    @tags = Note.tag_counts_on(:tags)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
    @tag = Tag.find_by_slug(params[:slug])
    @notes = Note.tagged_with(@tag.name)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @tag }
    end
  end
end
