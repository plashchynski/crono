module Crono
  class Scheduler
    attr_accessor :jobs

    def initialize
      self.jobs = []
    end

    def add(job)
      jobs << job
    end

    def next
      queue.first
    end

  private
    def queue
      jobs.sort { |a,b| a.next <=> b.next }
    end
  end
end
