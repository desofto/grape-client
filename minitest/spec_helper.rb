require 'minitest/spec'
require 'minitest/autorun'
require 'minitest-vcr'

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'grape_client'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'minitest/cassettes'
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

MinitestVcr::Spec.configure!

GrapeClient.configure do |c|
  c.site     = 'http://localhost:3000'
  c.user     = 'user'
  c.password = 'password'
  c.prefix   = '/api/v1/'
end
