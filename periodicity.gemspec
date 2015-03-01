# -*- encoding: utf-8 -*-
require File.expand_path('../lib/periodicity/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "periodicity"
  s.version     = Periodicity::VERSION
  s.authors     = ["Dzmitry Plashchynski"]
  s.email       = ["plashchynski@gmail.com"]
  s.homepage    = "https://github.com/plashchynski/periodicity"
  s.description = s.summary = "Job scheduler for Rails"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "periodicity"

  s.add_runtime_dependency      "activejob"
  s.add_runtime_dependency      "activesupport"
  s.add_development_dependency  "rake"
  s.add_development_dependency  "bundler", ">= 1.0.0"
  s.add_development_dependency  "rspec", "~> 3.0"
  s.add_development_dependency  "timecop"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
