class SessionsController < Devise::SessionsController
  def event
    @event = params[:event]
    render :event
  end
end
