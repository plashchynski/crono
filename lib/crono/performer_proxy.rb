module Crono
  class PerformerProxy
    def initialize(performer, schedule)
      @performer = performer
      @schedule = schedule
    end

    def every(period, *args)
      job = Job.new(@performer, Period.new(period, *args))
      @schedule.add(job)
    end
  end

  def self.perform(performer)
    PerformerProxy.new(performer, Crono.schedule)
  end
end
