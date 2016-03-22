require 'spec_helper'

class User < GrapeClient::Base
  self.site     = 'http://localhost:3000'
  self.user     = 'user'
  self.password = 'password'
  self.prefix = '/api/v1/'

  field_accessor :id, :email
end

describe GrapeClient::Base, :vcr do
  describe '.count' do
    it 'returns number of entities' do
      users = User.all

      expect(users.count).to eq 300
    end
  end

  describe '.find' do
    it 'searches entity by id' do
      user = User.find(2)

      expect(user.id).to eq 2
    end

    it 'searches entity by email' do
      user = User.find(email: 'test-103@example.com')

      expect(user.id).to eq 104
    end

    it 'returns nil for unexisted entity' do
      user = User.find(email: 'qwe')

      expect(user).to eq nil
    end
  end

  describe '.each' do
    it 'iterates entities' do
      users = User.all

      count = 0
      users.each { |_user| count += 1 }

      expect(count).to eq 300
    end
  end

  describe '.map' do
    it 'iterates entities' do
      users = User.all
      ids = users.map(&:id)

      expect(ids.count).to eq 300
    end
  end

  describe '.collect' do
    it 'collects entities' do
      users = User.all.collect

      expect(users.count).to eq 300
    end
  end

  describe '#save' do
    it 'saves user' do
      user = User.find(2)

      user.email = 'test@example.com'
      user.save
      user.reload

      expect(user.email).to eq 'test@example.com'
    end
  end

  describe '.create' do
    it 'creates user' do
      user = User.create(email: 'test@example.com')
      user.reload

      expect(user.id).not_to be_nil
      expect(user.email).to eq 'test@example.com'
    end
  end

  describe '#destroy' do
    it 'removes user' do
      user = User.find(2)

      user.destroy

      expect { user.reload }.to raise_error GrapeClient::Connection::UnknownError
    end
  end
end
