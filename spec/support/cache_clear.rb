RSpec.configure do |config|
  config.before(:each) do
    GrapeClient::Cache.instance.clear
  end
end
