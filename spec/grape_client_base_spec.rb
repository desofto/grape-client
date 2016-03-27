require 'spec_helper'

class User < GrapeClient::Base
  attr_accessor :id, :email

  belongs_to :group
  belongs_to :preloaded_group,
    class_name: :Group
end

class UserWithName < User
  self.site = 'https://localhost:3333'

  attr_accessor :name
end

class Group < GrapeClient::Base
  attr_accessor :id, :name

  has_many :users

  has_many :lazy_users,
    class_name: :User
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

  describe '.where' do
    it 'returns entities' do
      users = User.where(email: 'test-103@example.com')

      expect(users.count).to eq 1
    end
  end

  describe '.each' do
    it 'iterates entities' do
      users = User.all

      count = 0
      users.each { |_user| count += 1 }

      expect(count).to eq 300
    end

    it 'returns starts from first page' do
      users = User.all

      count = 0
      users.each { |_user| count += 1 }

      expect(count).to eq 300

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

    it 'fails on invalid user' do
      user = User.new

      msg = '{"error":"user is missing, user[email] is missing, user[group_id] is missing"}'
      expect { user.save! }.to raise_error GrapeClient::Connection::UnknownError, msg
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

  describe '.belongs_to' do
    it 'creates nested objects' do
      group = Group.create(name: 'test')
      user = User.create(email: 'test@example.com', group: group)

      expect(user.reload.group.name).to eq 'test'
    end

    it 'creates pre-loaded nested objects' do
      group = Group.create(name: 'test')
      user = User.create(email: 'test@example.com', group: group)

      expect(user.reload.preloaded_group.name).to eq 'test'
    end
  end

  describe '.has_many' do
    it 'returns objects' do
      group = Group.create(name: 'test')
      User.create(email: 'test_1@example.com', group: group)
      User.create(email: 'test_2@example.com', group: group)

      emails = group.reload.users.map(&:email)
      expect(emails).to match_array ['test_1@example.com', 'test_2@example.com']
    end

    it 'requests for objects' do
      group = Group.create(name: 'test')
      User.create(email: 'test_1@example.com', group: group)
      User.create(email: 'test_2@example.com', group: group)

      group.reload
      expect(group.lazy_users).not_to be_empty

      emails = group.lazy_users.map(&:email)
      expect(emails).to match_array ['test_1@example.com', 'test_2@example.com']
    end
  end

  it 'fails on wrong authentication' do
    User.user = 'qwe'

    expect { User.all }.to raise_error GrapeClient::Connection::Unauthorized

    User.user = 'user'
  end

  it 'fails on incorrect request' do
    expect { User.connection.request(:qwe, User.site) }.to raise_error GrapeClient::Connection::UndefinedMethod
  end

  describe '.attributes' do
    it 'User' do
      expect(User.site).to match 'http://localhost:3000'
      expect(User.attributes).to match [:id, :email, :group_id, :preloaded_group_id]
    end

    it 'Group' do
      expect(Group.site).to match 'http://localhost:3000'
      expect(Group.attributes).to match [:id, :name]
    end

    it 'UserWithName' do
      expect(UserWithName.site).to match 'https://localhost:3333'
      expect(UserWithName.attributes).to match [:id, :email, :group_id, :preloaded_group_id, :name]
    end
  end
end
