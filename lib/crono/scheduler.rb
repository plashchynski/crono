module Crono
  class Scheduler
    attr_accessor :jobs

    def initialize
      self.jobs = []
    end

    def add_job(job)
      job.load
      jobs << job
    end

    def next
      queue.first
    end

  private
    def queue
      jobs.sort_by(&:next)
    end
  end
end
