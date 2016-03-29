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
  before(:each) do
    GrapeClient::Cache.instance.clear
  end

  describe '.count', :vcr do
    it 'returns number of entities' do
      users = User.all

      users.count.must_equal 300
    end
  end

  describe '.find' do
    it 'searches entity by id' do
      user = User.find(2)

      user.id.must_equal 2
    end

    it 'searches entity by email' do
      user = User.find(email: 'test-103@example.com')

      user.id.must_equal 104
    end

    it 'returns nil for unexisted entity' do
      user = User.find(email: 'qwe')

      user.must_be_nil
    end
  end

  describe '.where' do
    it 'returns entities' do
      users = User.where(email: 'test-103@example.com')

      users.count.must_equal 1
    end
  end

  describe '.each' do
    it 'iterates entities' do
      users = User.all

      count = 0
      users.each { |_user| count += 1 }

      count.must_equal 300
    end

    it 'returns starts from first page' do
      users = User.all

      count = 0
      users.each { |_user| count += 1 }

      count.must_equal 300

      count = 0
      users.each { |_user| count += 1 }

      count.must_equal 300
    end
  end

  describe '.map' do
    it 'iterates entities' do
      users = User.all
      ids = users.map(&:id)

      ids.count.must_equal 300
    end
  end

  describe '.collect' do
    it 'collects entities' do
      users = User.all.collect

      users.count.must_equal 300
    end
  end

  describe '#save' do
    it 'saves user' do
      user = User.find(2)

      user.email = 'test@example.com'
      user.save
      user.reload

      user.email.must_equal 'test@example.com'
    end

    it 'returns false on invalid user' do
      user = User.new

      user.save.must_equal false
    end

    it 'fails on invalid user' do
      user = User.new

      msg = '{"error":"user is missing, user[email] is missing, user[group_id] is missing"}'
      proc { user.save! }.must_raise(GrapeClient::Connection::UnknownError, msg)
    end
  end

  describe '.create' do
    it 'creates user' do
      user = User.create(email: 'test@example.com')
      user.reload

      refute_nil user.id
      user.email.must_equal 'test@example.com'
    end
  end

  describe '#destroy' do
    it 'removes user' do
      user = User.find(2)

      user.destroy

      proc { user.reload }.must_raise GrapeClient::Connection::UnknownError
    end
  end

  describe '.belongs_to' do
    it 'creates nested objects' do
      group = Group.create(name: 'test')
      user = User.create(email: 'test@example.com', group: group)

      user.reload.group.name.must_equal 'test'
    end

    it 'creates pre-loaded nested objects' do
      group = Group.create(name: 'test')
      user = User.create(email: 'test@example.com', group: group)

      user.reload.preloaded_group.name.must_equal 'test'
    end
  end

  describe '.has_many' do
    it 'returns objects' do
      group = Group.create(name: 'test')
      User.create(email: 'test_1@example.com', group: group)
      User.create(email: 'test_2@example.com', group: group)

      emails = group.reload.users.map(&:email)
      emails.must_equal ['test_1@example.com', 'test_2@example.com']
    end

    it 'requests for objects' do
      group = Group.create(name: 'test')
      User.create(email: 'test_1@example.com', group: group)
      User.create(email: 'test_2@example.com', group: group)

      group.reload
      group.lazy_users.any?.must_equal true
      group.lazy_users.empty?.must_equal false

      emails = group.lazy_users.map(&:email)
      emails.must_equal ['test_1@example.com', 'test_2@example.com']
    end
  end

  it 'fails on wrong authentication' do
    User.user = 'qwe'

    proc { User.all }.must_raise GrapeClient::Connection::Unauthorized

    User.user = 'user'
  end

  it 'fails on incorrect request' do
    proc { User.connection.request(:qwe, User.site) }.must_raise GrapeClient::Connection::UndefinedMethod
  end

  describe '.attributes' do
    it 'User' do
      User.site.must_equal 'http://localhost:3000'
      User.attributes.must_equal [:id, :email, :group_id, :preloaded_group_id]
    end

    it 'Group' do
      Group.site.must_equal 'http://localhost:3000'
      Group.attributes.must_equal [:id, :name]
    end

    it 'UserWithName' do
      UserWithName.site.must_equal 'https://localhost:3333'
      UserWithName.attributes.must_equal [:id, :email, :group_id, :preloaded_group_id, :name]
    end
  end
end
