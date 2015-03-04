module Crono
  class Job
    attr_accessor :performer
    attr_accessor :period
    attr_accessor :last_performed_at

    def initialize(performer, period)
      self.performer, self.period = performer, period
    end

    def next
      period.next(since: last_performed_at)
    end

    def perform
      Crono.logger.info "Perform #{performer}"
      self.last_performed_at = Time.now
      Thread.new { performer.new.perform }
    end
  end
end
