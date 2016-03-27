GrapeClient.configure do |c|
  c.site     = 'http://localhost:3000'
  c.user     = 'user'
  c.password = 'password'
  c.prefix   = '/api/v1/'
end
