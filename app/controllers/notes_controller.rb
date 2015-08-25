class NotesController < ApplicationController
  add_breadcrumb I18n.t('notes.index.title'), :notes_path

  def index
    @page_number = params[:page] ||= 1
    all_notes = Note.note.unscoped.dateordered.publishable.listable.blurbable

    @notes = all_notes.page(@page_number).load
    @map = all_notes.mappable
    @total_count = all_notes.size
    @word_count = all_notes.sum(:word_count)
  end

  def map
    @notes = Note.note.unscoped.dateordered.publishable.listable.blurbable
    @word_count = @notes.sum(:word_count)

    @map = mapify(@notes)

    add_breadcrumb I18n.t('map'), notes_map_path
  end

  def show
    @note = Note.note.publishable.find(params[:id])
    note_tags(@note)
    note_map(@note)
    note_source(@note)
    commontator_thread_show(@note)

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
  end

  def version
    @note = Note.note.publishable.find(params[:id])
    @diffed_version = DiffedNoteVersion.new(@note, params[:sequence].to_i)
    @diffed_tag_list = DiffedNoteTagList.new(@diffed_version.previous_tag_list, @diffed_version.tag_list).list

    add_breadcrumb I18n.t('notes.show.title', id: @note.id), note_path(@note)
    add_breadcrumb I18n.t('notes.version.title', sequence: @diffed_version.sequence), note_version_path(@note, @diffed_version.sequence)

    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('notes.show.not_found', id: params[:id])
      redirect_to notes_path
    rescue
      flash[:error] = t('notes.version.not_found', id: params[:id], sequence: params[:sequence])
      redirect_to note_path(@note)
  end
end
