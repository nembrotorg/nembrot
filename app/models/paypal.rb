# encoding: utf-8

class Paypal
  include HTTParty

  def process_pdt(params)
    # https://developer.paypal.com/webapps/developer/docs/classic/paypal-payments-standard/integration-guide/paymentdatatransfer/
    # Temporarily upgrades user's account (pending IPN)
    users = User.where(token_for_paypal: params[:cm])
    pdt_not_repeated = true # User.where(paypal_last_tx: params[:tx]).empty?

    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:cm] }."
      message_type = :error
        message = '<span id="cancelled-upgrade">An error has occurred.</span>'
    elsif params[:st] == 'Completed' && !users.empty?
      user = users.first
      if pdt_not_repeated
        user.update_from_paypal_callback!(params)
        message_type = :notice
        message = '<span id="successful-upgrade">You are now a Premium user. Thanks!</span>'
        verify_pdt(params)
      else
        message_type = :error
        message = '<span id="cancelled-upgrade">Your upgrade was cancelled.</span>'
        PAY_LOG.error "Paypal tx parameter in callback not unique: #{ params[:tx] }. (Sig: #{ params[:sig] }.)"
      end
    else
      message_type = :error
      message = '<span id="cancelled-upgrade">Your upgrade was cancelled.</span>'
      PAY_LOG.info "User #{ users.first.id } upgrade cancelled by browser redirect. (Status: params[:st].)"
    end
    [message_type, message]
  end

  def verify_pdt(params)
    request_uri = URI.parse('https://www.paypal.com/cgi-bin/webscr')
    request_uri.scheme = 'https'
    response = self.class.post(
      request_uri.to_s,
      :body => params.merge(
        'cmd' => '_notify-synch',
        'tx'  => params[:tx],
        'at'  => Secret.auth.paypal.secret
      )
    )
    # Even if PDT fails, we provisionally upgrade user, pending IPN
    parsed_response = response.body.split('\n')
    status = parsed_response.shift

    response_params = {}
    parsed_response.each do |line|
      pair = line.split('\n')
      response_params[pair.first.to_sym] = CGI.unescape(pair.last)
    end

    update_from_pdt!(response_params) if status == 'SUCCESS'
  end

  def process_ipn(params)
    ipn_not_repeated = true # User.where(paypal_last_ipn: params[:ipn_track_id]).empty?
    verified_ipn_message = verify_ipn?(params)
    verified_receiver = verify_receiver?(params)

    if ipn_not_repeated && verified_ipn_message && verified_receiver
      # REVIEW: Change this if we're not processing more types here
      case params[:txn_type]
      when 'subscr_signup'
        ipn_subscr_signup(params)
      when 'subscr_payment'
        ipn_subscr_payment(params)
      when 'subscr_cancel'
        ipn_subscr_cancel(params)
      end
    else
      PAY_LOG.warn "Wrong receiver in Paypal IPN. (IPN id: #{ params[:ipn_track_id] }.)" unless verified_receiver
      PAY_LOG.warn "Repeat IPN received from Paypal. (IPN id: #{ params[:ipn_track_id] }.)" unless ipn_not_repeated
      PAY_LOG.warn "Paypal IPN failed verification. (IPN id: #{ params[:ipn_track_id] }.)" unless verified_ipn_message
    end
  end

  def verify_ipn?(params)
    request_uri = URI.parse('https://www.paypal.com/cgi-bin/webscr')
    request_uri.scheme = 'https'
    self.class.post(
      request_uri.to_s,
      :body => params.merge('cmd' => '_notify-validate')
    ).body == 'VERIFIED'
  end

  def verify_receiver?(params)
    params[:receiver_email] == 'joe.gatt@nembrot.com'
  end

  def ipn_subscr_signup(params)
    users = User.where(token_for_paypal: params[:custom])
    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:custom] } while upgrading. (IPN id: #{ params[:ipn_track_id] }.)"
    else
      # No unique data comes from subscription notice, skip it
      # users.first.update_subscription_from_paypal_ipn!(params)
    end
  end

  def ipn_subscr_payment(params)
    users = User.where(token_for_paypal: params[:custom])
    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:custom] } while paying. (IPN id: #{ params[:ipn_track_id] }.)"
    else
      users.first.update_payment_from_paypal_ipn!(params)
    end
  end

  def ipn_subscr_cancel(params)
    users = User.where(token_for_paypal: params[:custom])
    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:custom] } while cancelling. (IPN id: #{ params[:ipn_track_id] }.)"
    else
      users.first.update_cancellation_from_paypal_ipn!(params)
    end
  end
end
