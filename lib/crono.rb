# Crono main module
module Crono
end

require 'active_support/all'
require 'crono/version'
require 'crono/logging'
require 'crono/period'
require 'crono/job'
require 'crono/scheduler'
require 'crono/config'
require 'crono/performer_proxy'
require 'crono/orm/active_record/crono_job'

Crono.autoload :Web, 'crono/web'
