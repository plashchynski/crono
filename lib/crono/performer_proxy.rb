module Crono
  # Crono::PerformerProxy is a proxy used in cronotab.rb semantic
  class PerformerProxy
    def initialize(performer, scheduler)
      @performer = performer
      @scheduler = scheduler
    end

    def every(period, *args)
      @job = Job.new(@performer, Period.new(period, *args))
      @scheduler.add_job(@job)
      self
    end

    def once_per(execution_interval)
      @job.execution_interval = execution_interval if @job
      self
    end
  end

  def self.perform(performer)
    PerformerProxy.new(performer, Crono.scheduler)
  end
end
