module Crono
  # Crono::PerformerProxy is a proxy used in cronotab.rb semantic
  class PerformerProxy
    def initialize(performer, scheduler, data)
      @performer = performer
      @scheduler = scheduler
      @data = data
    end

    def every(period, *args)
      @job = Job.new(@performer, Period.new(period, *args), @data)
      @scheduler.add_job(@job)
      self
    end

    def once_per(execution_interval)
      @job.execution_interval = execution_interval if @job
      self
    end
  end

  def self.perform(performer, data=nil)
    PerformerProxy.new(performer, Crono.scheduler, data)
  end
end
