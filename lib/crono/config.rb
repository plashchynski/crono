module Crono
  class Config
    CRONOTAB = "config/cronotab.rb"
    include Singleton

    attr_accessor :schedule
    attr_accessor :cronotab

    def initialize
      self.schedule = Schedule.new
      self.cronotab = CRONOTAB
    end
  end

  def self.config
    Config.instance
  end
end
