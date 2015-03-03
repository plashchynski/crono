module Crono
  class Config
    CRONOTAB  = "config/cronotab.rb"
    LOGFILE   = "log/crono.log"
    PIDFILE   = "tmp/pids/crono.pid"

    attr_accessor :cronotab
    attr_accessor :logfile
    attr_accessor :pidfile
    attr_accessor :daemonize

    def initialize
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
      self.pidfile  = PIDFILE
      self.daemonize = false
    end
  end
end
