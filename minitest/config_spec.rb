require 'spec_helper'

describe GrapeClient do
  describe 'configuration' do
    before do
      GrapeClient.configure do |c|
        c.site     = 'http://localhost:3000'
        c.user     = 'user'
        c.password = 'password'
        c.prefix   = '/api/v1/'
      end
    end

    it 'sets site' do
      GrapeClient.configuration.site.must_equal 'http://localhost:3000'
    end

    it 'sets user' do
      GrapeClient.configuration.user.must_equal 'user'
    end

    it 'sets password' do
      GrapeClient.configuration.password.must_equal 'password'
    end

    it 'sets prefix' do
      GrapeClient.configuration.prefix.must_equal '/api/v1/'
    end
  end
end
