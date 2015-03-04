module Crono
  class Schedule
    attr_accessor :schedule

    def initialize
      self.schedule = []
    end

    def add(job)
      schedule << job
    end

    def next
      queue.first
    end

  private
    def queue
      schedule.sort { |a,b| a.next <=> b.next }
    end
  end
end
