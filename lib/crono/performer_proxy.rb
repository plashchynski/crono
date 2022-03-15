module Crono
  # Crono::PerformerProxy is a proxy used in cronotab.rb semantic
  class PerformerProxy
    def initialize(performer, scheduler, job_args)
      @performer = performer
      @scheduler = scheduler
      @job_args = job_args
    end

    def every(period, at: nil, on: nil, within: nil)
      @job = Job.new(
        @performer,
        Period.new(period, at: at, on: on, within: within),
        @job_args,
        @options,
      )
      @scheduler.add_job(@job)
      self
    end

    def once_per(execution_interval)
      @job.execution_interval = execution_interval if @job
      self
    end

    def with_options(options)
      @options = options
      self
    end
  end

  def self.perform(performer, *job_args)
    PerformerProxy.new(performer, Crono.scheduler, job_args)
  end
end
