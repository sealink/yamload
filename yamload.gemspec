# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yamload/version'

Gem::Specification.new do |spec|
  spec.name          = 'yamload'
  spec.version       = Yamload::VERSION
  spec.authors       = ['Alessandro Berardi']
  spec.email         = ['berardialessandro@gmail.com']
  spec.summary       = 'YAML files loader'
  spec.description   = 'YAML files loader with validation'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'anima', '~> 0.2'
  spec.add_dependency 'facets', '~> 3.0'
  spec.add_dependency 'respect', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rubocop'
end
