module Crono
  class Job
    include Logging

    attr_accessor :performer
    attr_accessor :period
    attr_accessor :last_performed_at

    def initialize(performer, period)
      self.performer, self.period = performer, period
    end

    def next
      period.next(since: last_performed_at)
    end

    def description
      "Perform #{performer} #{period.description}"
    end

    def job_id
      description
    end

    def perform
      logger.info "Perform #{performer}"
      self.last_performed_at = Time.now
      Thread.new do
        performer.new.perform
        logger.info "Finished #{performer} in %.2f seconds" % (Time.now - last_performed_at)
      end
    end

    def save
      model.update(last_performed_at: last_performed_at)
    end

  private
    def model
      @model ||= Crono::CronoJob.find_or_create_by(job_id: job_id)
    end
  end
end
