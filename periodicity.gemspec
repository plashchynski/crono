# -*- encoding: utf-8 -*-
require File.expand_path('../lib/periodicity/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'periodicity'
  gem.version     = Periodicity::VERSION
  gem.description = gem.summary = "Job scheduler for Rails"
  gem.authors     = ["Dzmitry Plashchynski"]
  gem.email       = "plashchynski@gmail.com"
  gem.files       = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]
  gem.homepage    = "https://github.com/plashchynski/periodicity"
  gem.license     = "Apache-2.0"
end
