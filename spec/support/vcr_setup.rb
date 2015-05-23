require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
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

RSpec.configure do |c|
  c.around(:example) do |example|
    # SEE https://github.com/vcr/vcr/issues/8
    VCR.use_cassette(example.metadata[:type], record: :new_episodes, match_requests_on: [:uri, :body]) do
      example.run
    end
  end
end
