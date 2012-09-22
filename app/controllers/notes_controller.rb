class NotesController < ApplicationController

  def index
    @notes = Note.find(:all)

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @note = Note.find(params[:id])
    @tags = @note.tags

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end

  def version
    @note = Note.find(params[:id])

    # Can this go in the model?

    if params[:sequence].to_i == 1
      @version = @note.versions.find_by_sequence(params[:sequence]).reify
      @previous = OpenStruct.new({
        :title => '',
        :body => ''
      })
      @sequence = 1
      version_tags = @version.version.tags
      previous_tags = Array.new
    elsif params[:sequence].to_i == @note.versions.length + 1
      @version = @note
      @previous = @note.versions.last.reify
      @sequence = @note.versions.length + 1
      version_tags = @version.tags
      previous_tags = @previous.version.tags
    else        
      @version = @note.versions.find_by_sequence(params[:sequence]).reify
      @previous = @version.previous_version    
      @sequence = params[:sequence]
      version_tags = @version.version.tags
      previous_tags = @previous.version.tags
    end

    @version.title = Differ.diff_by_word(@version.title, @previous.title)
    @version.body = Differ.diff_by_word(@version.body, @previous.body)

    @removed_tags = previous_tags - version_tags
    @added_tags = version_tags - previous_tags

    # tags default scope: sort by tag.name.downcase
    # _tags should go in :instructions
    @tags = (version_tags + previous_tags).find_all { |tag| tag.name.match(/^[^_]/) }.uniq.sort_by { |tag| tag.name.downcase }

    respond_to do |format|
      format.html
      format.json { render :json => @note }
    end
  end
end
