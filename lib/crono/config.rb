module Crono
  # Crono::Config stores Crono configuration
  class Config
    CRONOTAB  = 'config/cronotab.rb'
    LOGFILE   = 'log/crono.log'
    PIDFILE   = 'tmp/pids/crono.pid'
    PIDDIR    = 'tmp/pids'
    PROCESS_NAME = 'crono'

    attr_accessor :cronotab, :logfile, :pidfile, :piddir, :process_name,
                  :monitor, :daemonize, :deprecated_daemonize, :environment

    def initialize
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
      self.piddir = PIDDIR
      self.process_name = PROCESS_NAME
      self.daemonize = false
      self.deprecated_daemonize = false
      self.monitor = false
      self.environment = ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def pidfile=(pidfile)
      @pidfile = pidfile
      self.process_name = Pathname.new(pidfile).basename(".*").to_s
      self.piddir = Pathname.new(pidfile).dirname.to_s 
    end

    def pidfile
      @pidfile || (deprecated_daemonize ? PIDFILE : nil)
    end
  end
end
