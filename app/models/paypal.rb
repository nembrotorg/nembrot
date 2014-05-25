# encoding: utf-8

class Paypal
  include HTTParty

  def process_pdt(params)
    # https://developer.paypal.com/webapps/developer/docs/classic/paypal-payments-standard/integration-guide/paymentdatatransfer/
    # Temporarily upgrades user's account (pending IPN)
    users = User.where(token_for_paypal: params[:cm])
    pdt_not_repeated = User.where(paypal_last_tx: params[:tx]).empty?

    if users.empty?
      PAY_LOG.error "No user found with token: #{ params[:cm] }."
      message_type = :error
      message = 'An error has occurred!'
      return
    elsif params[:st] == 'Completed' && !users.empty? 
      user = users.first
      if pdt_not_repeated
        update_from_paypal_callback!(params)
      else
        PAY_LOG.error "Paypal tx parameter in callback not unique: #{ params[:tx] }. (Sig: #{ params[:sig] }.)"
        return
      end
      message_type = :notice
      message = 'You are now a Premium user. Thanks!'
      verify_pdt(params)
      return
    else
      message_type = :error
      message = 'Your upgrade was cancelled.'
      PAY_LOG.info "User #{ users.first.id } upgrade cancelled by browser redirect. (Status: params[:st].)"
      return
    end
    message_type, message
  end

  def verify_pdt(params)
    request_uri = URI.parse('https://www.paypal.com/cgi-bin/webscr')
    request_uri.scheme = 'https'
    response = self.post(
      request_uri.to_s,
      :body => params.merge(
        'cmd' => '_notify-synch',
        'tx'  => params[:tx],
        'at'  => Secret.paypal.secret
      )
    )
    # Even if PDT fails, we provisionally upgrade user, pending IPN
    update_from_pdt!(response) if response.body == 'SUCCESS'
  end

  def process_ipn(params)
    ipn_not_repeated = User.where(paypal_last_ipn: params[:ipn_track_id]).empty?
    verified_ipn_message = verify_ipn?(params)

    if ipn_not_repeated && verified_ipn_message
      user = User.where(token_for_paypal: params[:custom]).first

      # REVIEW: Change this if we're not processing more types here
      case params[:txn_type]
      when 'subscr_signup'
        ipn_subscr_signup(user, params)
      end
    else
      PAY_LOG.warn "Repeat IPN received from Paypal. (IPN id: #{ params[:ipn_track_id] }.)" unless ipn_not_repeated
      PAY_LOG.warn "Paypal IPN failed verification. (IPN id: #{ params[:ipn_track_id] }.)" unless verified_ipn_message
    end
  end

  def verify_ipn?(params)
    request_uri = URI.parse('https://www.paypal.com/cgi-bin/webscr')
    request_uri.scheme = 'https'
    self.post(
      request_uri.to_s,
      :body => params.merge('cmd' => '_notify-validate')
    ).body == 'VERIFIED'
  end

  def ipn_subscr_signup(user, params)
    users = User.where(token_for_paypal: params[:custom])
    if user.nil?
      PAY_LOG.error "No user found with token: #{ params[:custom] }. (IPN id: #{ params[:ipn_track_id] }.)"
    else
      user.update_from_paypal_ipn!(params)
    end
  end
end
