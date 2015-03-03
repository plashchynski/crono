module Crono
  class PerformerProxy
    def initialize(performer, schedule)
      @performer = performer
      @schedule = schedule
    end

    def every(period, *args)
      @schedule.add(@performer, Period.new(period, *args))
    end
  end

  def self.perform(performer)
    PerformerProxy.new(performer, Crono.schedule)
  end
end
