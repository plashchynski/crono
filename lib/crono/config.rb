module Crono
  class Config
    CRONOTAB  = "config/cronotab.rb"
    LOGFILE   = "log/crono.rb"

    attr_accessor :cronotab
    attr_accessor :logfile
    attr_accessor :daemonize

    def initialize
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
      self.daemonize = false
    end
  end
end
