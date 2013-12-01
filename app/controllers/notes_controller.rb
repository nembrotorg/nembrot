class NotesController < ApplicationController

  add_breadcrumb I18n.t('notes.index.title'), :notes_path

  def index
    page_number = params[:page] ||= 1
    all_notes = Note.publishable.listable.blurbable

    @notes = all_notes.page(page_number).load
    @map = all_notes.mappable
    @total_count = all_notes.size
    @word_count = all_notes.sum(:word_count)

    respond_to do |format|
      format.html
      format.atom
      format.json { render json: @notes }
    end
  end

  def map
    @notes = Note.publishable.listable.blurbable.mappable
    @word_count = @notes.sum(:word_count)

    @map = mapify(@notes)

    add_breadcrumb I18n.t('map'), notes_map_path

    respond_to do |format|
      format.html
      format.json { render json: @notes }
    end
  end

  def show
    @note = Note.publishable.find(params[:id])
    @tags = @note.tags.keep_if { |tag| Note.publishable.tagged_with(tag).size >= Setting['advanced.tags_minimum'].to_i }

    commontator_thread_show(@note)

    @map = mapify(@note) if @note.has_instruction?('map') && !@note.inferred_latitude.nil?


    if @note.has_instruction?('enface')
      @source = Note.where(title: @note.title).where.not(lang: @note.lang).first
    end

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)
    # add_breadcrumb I18n.t('notes.versions.show.title', sequence: @note.versions.size),
    # note_version_path(@note, @note.versions.size)

    respond_to do |format|
      format.html
      format.json { render json: @note }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
  end

  def version
    @note = Note.publishable.find(params[:id])
    @diffed_version = DiffedNoteVersion.new(@note, params[:sequence].to_i)
    @diffed_tag_list = DiffedNoteTagList.new(@diffed_version.previous_tag_list, @diffed_version.tag_list).list

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)
    add_breadcrumb I18n.t('notes.version.title', sequence: @diffed_version.sequence), note_version_path(@note, @diffed_version.sequence)

    respond_to do |format|
      format.html
      format.json { render json: @diffed_version }
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
    rescue
      flash[:error] = t('notes.version.not_found', id: params[:id], sequence: params[:sequence])
      redirect_to note_path(@note)
  end
end
