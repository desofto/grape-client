require 'spec_helper'

RSpec.describe GrapeClient do
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
      expect(GrapeClient.configuration.site).to eq 'http://localhost:3000'
    end

    it 'sets user' do
      expect(GrapeClient.configuration.user).to eq 'user'
    end

    it 'sets password' do
      expect(GrapeClient.configuration.password).to eq 'password'
    end

    it 'sets prefix' do
      expect(GrapeClient.configuration.prefix).to eq '/api/v1/'
    end
  end
end
