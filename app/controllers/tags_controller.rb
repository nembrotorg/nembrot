class TagsController < ApplicationController
  # GET /tags
  # GET /tags.json
  def index
    # Can this be a scope in noteversions?
    # Is this working as expected?
    # Better to put a latest Boolean field in table then scope it  
    @tags = NoteVersion
              .current
              .tag_counts_on(:tags)
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
    @tag = Tag.where('lower(name) = ?', params[:id])
    @notes = NoteVersion.tagged_with(params[:id]).group('note_id')
    #@notes = Note.find(:all, :order => 'updated_at DESC')
    #@notes = Note.note_versions.tagged_with(params[:name])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @tag }
    end
  end
end
