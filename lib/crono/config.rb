module Crono
  # Crono::Config stores Crono configuration
  class Config
    CRONOTAB  = 'config/cronotab.rb'
    LOGFILE   = 'log/crono.log'
    PIDFILE   = 'tmp/pids/crono.pid'

    attr_accessor :cronotab, :logfile, :pidfile, :daemonize, :environment

    def initialize
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
      self.daemonize = false
      self.environment = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def pidfile
      @pidfile || (daemonize ? PIDFILE : nil)
    end
  end
end
