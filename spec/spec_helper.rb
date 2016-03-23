$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require 'grape_client'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
  end
end
