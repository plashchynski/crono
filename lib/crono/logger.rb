module Crono
  class Logger < ::Logger
    include Singleton

    def initialize
      super(Crono.config.daemonize ? Crono.config.logfile : STDOUT) 
      self.level = Logger::DEBUG
    end
  end

  def self.logger
    Logger.instance
  end
end
