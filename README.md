# GrapeClient
[![Build Status](https://travis-ci.org/desofto/grape-client.svg?branch=master)](https://travis-ci.org/desofto/grape-client)
[![Code Climate](https://codeclimate.com/github/desofto/grape-client/badges/gpa.svg)](https://codeclimate.com/github/desofto/grape-client)
[![Test Coverage](https://codeclimate.com/github/desofto/grape-client/badges/coverage.svg)](https://codeclimate.com/github/desofto/grape-client/coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-client

## Usage

```ruby
class User < GrapeClient::Base
  self.site     = 'http://localhost:3000'
  self.user     = 'user'
  self.password = 'password'
  self.prefix = '/api/v1/'

  field_accessor :id, :email
end

u = User.create(email: 'test@example.com')
u.email = 'another@example.com'
u.save!
u.reload

u = User.find(2)
u.destroy

User.all.each do |user|
  ...
end
```

## Contributing

1. Fork it ( https://github.com/desofto/grape-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
