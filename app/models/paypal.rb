# encoding: utf-8

class Paypal
  include HTTParty

  def self.verify(params)
    request_uri = URI.parse('https://www.paypal.com/cgi-bin/webscr')
    request_uri.scheme = 'https'
    self.post(
      request_uri.to_s,
      :body => params.merge('cmd' => '_notify-validate')
    ).body == 'VERIFIED'
  end
end
