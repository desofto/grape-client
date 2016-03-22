require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!(allow: 'codeclimate.com')

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/cassettes'
  c.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :path, :query, :body]
  }
  c.before_record { |i| i.response.body.force_encoding 'UTF-8' }
  c.before_record do |i|
    i.request.headers.clear
    save_headers = %w(Total Per-Page Link Content-Type Content-Length)
    i.response.headers.select! { |key| save_headers.include? key }
  end
  c.ignore_hosts 'codeclimate.com'
end
