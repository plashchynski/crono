module Crono
  # Scheduler is a container for job list and queue
  class Scheduler
    attr_accessor :jobs

    def initialize
      self.jobs = []
    end

    def add_job(job)
      job.load
      jobs << job
    end

    def next_jobs
      jobs.group_by(&:next).sort_by {|time,_| time }.first
    end
  end

  mattr_accessor :scheduler
end
