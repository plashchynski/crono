module Crono
  class Config
    include Singleton
    CRONOTAB  = "config/cronotab.rb"
    LOGFILE   = "log/crono.rb"

    attr_accessor :schedule
    attr_accessor :cronotab
    attr_accessor :logfile
    attr_accessor :daemonize

    def initialize
      self.schedule = Schedule.new
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
      self.daemonize = false
    end
  end

  def self.config
    Config.instance
  end
end
