module Crono
  class Config
    include Singleton

    attr_accessor :schedule

    def initialize
      self.schedule = Schedule.new
    end
  end
end
