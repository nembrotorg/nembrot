# encoding: utf-8

class EvernoteNotesController < ApplicationController

  def add_task
    EvernoteNote.add_task(params[:guid])

    if Settings.synchronous
      EvernoteNote.sync_all
      Resource.sync_all_binaries
      Book.sync_all
      Link.sync_all
    end

    render :json => { 'status' => 'OK' }
  end
end
