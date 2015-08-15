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
  ENV.each do |key, value|
    c.filter_sensitive_data("<#{ key }>".upcase) { value }
  end
end
