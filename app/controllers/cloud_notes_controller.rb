class CloudNotesController < ApplicationController

  include ActionView::Helpers::SanitizeHelper
  include EvernoteHelper

  def update_cloud
    result = add_evernote_task(params[:guid], true)

    render :json => { "status" => result }
  end
end
