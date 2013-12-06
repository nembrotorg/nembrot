module Commontator
  class SubscriptionsController < Commontator::ApplicationController
    before_filter :get_thread

    # PUT /threads/1/subscribe
    def subscribe
      fail SecurityTransgression unless @thread.can_subscribe?(@user)

      @thread.errors.add(:subscription, 'You are already subscribed to this thread') \
        unless @thread.subscribe(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :subscribe }
      end

    end

    # PUT /threads/1/unsubscribe
    def unsubscribe
      fail SecurityTransgression unless @thread.can_subscribe?(@user)

      @thread.errors.add(:subscription, 'You are not subscribed to this thread') \
        unless @thread.unsubscribe(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :subscribe }
      end
    end
  end
end
