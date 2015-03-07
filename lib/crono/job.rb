require 'stringio'
require 'logger'

module Crono
  class Job
    include Logging

    attr_accessor :performer
    attr_accessor :period
    attr_accessor :last_performed_at
    attr_accessor :job_log
    attr_accessor :job_logger

    def initialize(performer, period)
      self.performer, self.period = performer, period
      self.job_log = StringIO.new
      self.job_logger = Logger.new(job_log)
    end

    def next
      next_time = period.next(since: last_performed_at)
      next_time.past? ? period.next : next_time
    end

    def description
      "Perform #{performer} #{period.description}"
    end

    def job_id
      description
    end

    def perform
      log "Perform #{performer}"
      self.last_performed_at = Time.now
      save
      Thread.new do
        performer.new.perform
        log "Finished #{performer} in %.2f seconds" % (Time.now - last_performed_at)
      end
    end

    def save
      model.update(last_performed_at: last_performed_at)
    end

    def load
      self.last_performed_at = model.last_performed_at
    end

  private
    def log(message)
      logger.info message
      job_logger.info message
    end

    def model
      @model ||= Crono::CronoJob.find_or_create_by(job_id: job_id)
    end
  end
end
