class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    # Can this be a scope in noteversions?
    # Is this working as expected?
    # Better to put a latest Boolean field in table then scope it  
    @tags = Note.tag_counts_on(:tags)
              .find_all { |tag| tag.name.match(/^[^_]/) }
              .sort_by { |tag| tag.name.downcase }

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
    #@notes = Note.find(:all, :order => 'updated_at DESC')
    #@notes = Note.note_versions.tagged_with(params[:name])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @tag }
    end
  end
end
