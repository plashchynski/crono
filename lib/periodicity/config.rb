module Periodicity
  class Config
    include Singleton

    attr_accessor :schedule

    def initialize
      self.schedule = []
    end
  end
end
