# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'grape-client'
  spec.version       = GrapeClient::VERSION
  spec.authors       = ['Dmitry Silchenko']
  spec.email         = ['dmitry@desofto.com']

  spec.summary       = 'Simple access from your client to Grape APIs.'
  spec.description   = 'Simple access from your client to Grape APIs.'
  spec.homepage      = 'https://github.com/desofto/grape-client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency('activesupport', '~> 4.2')
end
