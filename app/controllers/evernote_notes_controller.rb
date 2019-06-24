# encoding: utf-8

class EvernoteNotesController < ApplicationController
  def add_task
    unless params[:guid].blank? || params[:notebookGuid].blank?
      EvernoteNote.add_task(params[:guid], params[:notebookGuid])
      render json: { 'Status' => 'OK' }

      if NB.synchronous == 'true'
        EvernoteNote.sync_all
        Resource.sync_all_binaries
        Book.sync_all
        Link.sync_all
      end
    else
      render json: { 'Status' => 'Refused: insufficient parameters.' }
    end
  end
end
