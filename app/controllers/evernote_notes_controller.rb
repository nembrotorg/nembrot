class EvernoteNotesController < ApplicationController

  def add_task
    EvernoteNote.add_task(params[:guid])

    if Settings.evernote.synchronous
      EvernoteNote.sync_all
      Resource.sync_all_binaries
    end

    render :json => { "status" => 'OK' }
  end
end
