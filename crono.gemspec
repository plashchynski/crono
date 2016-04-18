# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crono/version'

Gem::Specification.new do |spec|
  spec.name          = 'crono'
  spec.version       = Crono::VERSION
  spec.authors       = ['Dzmitry Plashchynski']
  spec.email         = ['plashchynski@gmail.com']

  spec.summary       = 'Job scheduler for Rails'
  spec.description   = 'A time-based background job scheduler daemon (just like Cron) for Rails'
  spec.homepage      = 'https://github.com/plashchynski/crono'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe' # http://bundler.io/blog/2015/03/20/moving-bins-to-exe.html
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 4.0'
  spec.add_runtime_dependency 'activerecord', '>= 4.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'bundler', '>= 1.0.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'timecop', '~> 0.7'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'haml'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'daemons'
end
