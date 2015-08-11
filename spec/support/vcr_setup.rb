require 'vcr'
require 'net/http'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.configure_rspec_metadata!
  c.default_cassette_options = {
    serialize_with: :yaml,
    decode_compressed_response: true
  }
  Secret.auth.each do |service_key, service_value|
    service_value.each do |param_key, param_value|
      c.filter_sensitive_data("<#{ service_key }_#{ param_key }>".upcase) { param_value }
    end
  end
end
