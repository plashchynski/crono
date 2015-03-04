module Crono
  class Job
    attr_accessor :performer
    attr_accessor :period

    def initialize(performer, period)
      self.performer, self.period = performer, period
    end

    def next
      period.next
    end

    def perform
      Crono.logger.info "Perform #{performer}"
      Thread.new { performer.new.perform }
    end
  end
end
