# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rom/pg_json/build_info'

Gem::Specification.new do |spec|
  spec.name          = "rom-pg-json"
  spec.homepage      = ''
  spec.require_paths = ['lib']

  Rom::PgJson::BuildInfo.new.add_to_gemspec(spec)

  spec.add_runtime_dependency 'rom'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rspec-core', '~> 3.2'
  spec.add_development_dependency 'rspec-mocks', '~> 3.2'
  spec.add_development_dependency 'rspec-expectations', '~> 3.2'
  spec.add_development_dependency 'rake', '~> 10.0'
end
