module Crono
  class Config
    include Singleton
    CRONOTAB  = "config/cronotab.rb"
    LOGFILE   = "log/crono.rb"

    attr_accessor :schedule
    attr_accessor :cronotab
    attr_accessor :logfile

    def initialize
      self.schedule = Schedule.new
      self.cronotab = CRONOTAB
      self.logfile  = LOGFILE
    end
  end

  def self.config
    Config.instance
  end
end
