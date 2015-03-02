module Periodicity
end

require "active_support/all"
require "periodicity/version.rb"
require "periodicity/period.rb"
require "periodicity/config.rb"
require 'periodicity/extensions/active_job'
require "periodicity/rails.rb" if defined?(::Rails::Engine)
