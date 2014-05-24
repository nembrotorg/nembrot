# See http://stackoverflow.com/questions/6021372/best-way-to-create-unique-token-in-rails

module Tokenable
  extend ActiveSupport::Concern

  def generate_token
    SecureRandom.urlsafe_base64(nil, false)
  end
end
