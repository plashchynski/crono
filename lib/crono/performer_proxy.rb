module Crono
  # Crono::PerformerProxy is a proxy used in cronotab.rb semantic
  class PerformerProxy
    def initialize(performer, scheduler, job_args = nil, job_options = nil)
      @performer = performer
      @scheduler = scheduler
      @job_args = job_args
      @job_options = job_options
    end

    def every(period, **options)
      @job = Job.new(@performer, Period.new(period, **options), @job_args, @job_options)
      @scheduler.add_job(@job)
      self
    end

    def once_per(execution_interval)
      @job.execution_interval = execution_interval if @job
      self
    end

    def with_options(options)
      @job_options = options
      self
    end
  end

  def self.perform(performer, *job_args)
    PerformerProxy.new(performer, Crono.scheduler, *job_args)
  end
end
