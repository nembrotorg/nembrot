class CloudNotesController < ApplicationController

  include ActionView::Helpers::SanitizeHelper
  include EvernoteHelper

  def add_evernote_task
    cloud_service = CloudService.where( :name => 'evernote' ).first_or_create
    cloud_note = CloudNote.where(:cloud_note_identifier => params[:guid], :cloud_service_id => cloud_service.id).first_or_create
    cloud_note.dirtify

    if Settings.evernote.synchronous
      CloudNote.sync_all_from_evernote
      Resource.sync_all_binaries
    end

    render :json => { "status" => 'OK' }
  end
end
