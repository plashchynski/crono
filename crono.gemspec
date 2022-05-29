# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'crono/version'

Gem::Specification.new do |s|
  s.name          = 'crono'
  s.version       = Crono::VERSION
  s.authors       = ['Dzmitry Plashchynski']
  s.email         = ['plashchynski@gmail.com']

  s.summary       = 'Job scheduler for Rails'
  s.description   = 'A time-based background job scheduler daemon (just like Cron) for Rails'
  s.homepage      = 'https://github.com/plashchynski/crono'
  s.license       = 'Apache-2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport', '>= 5.2.8'
  s.add_runtime_dependency 'activerecord', '>= 5.2.8'
  s.add_development_dependency 'rake', '>= 13.0.1'
  s.add_development_dependency 'bundler', '>= 2'
  s.add_development_dependency 'rspec', '>= 3.10'
  s.add_development_dependency 'timecop', '>= 0.7'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'daemons'
end
