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
  ENV.select { |x| x.match(/.*(key|secret|password).*/) }.keys.sort_by(&:length).reverse.each do |key|
    c.filter_sensitive_data("<#{ key.upcase }>") do
      ENV[key]
    end
  end
end
