require 'stringio'
require 'logger'

module Crono
  class Job
    include Logging

    attr_accessor :performer, :period, :last_performed_at, :job_log, :job_logger, :healthy

    def initialize(performer, period)
      self.performer, self.period = performer, period
      self.job_log = StringIO.new
      self.job_logger = Logger.new(job_log)
      @semaphore = Mutex.new
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

      Thread.new { perform_job }
    end

    def save
      @semaphore.synchronize do
        log = model.reload.log || ""
        log << job_log.string
        job_log.truncate(job_log.rewind)
        model.update(last_performed_at: last_performed_at, log: log, healthy: healthy)
      end
    end

    def load
      self.last_performed_at = model.last_performed_at
    end

  private
    def perform_job
      begin
        performer.new.perform
      rescue Exception => e
        log_error "Finished #{performer} in %.2f seconds with error: #{e.message}" % (Time.now - last_performed_at)
        log_error e.backtrace.join("\n")
        self.healthy = false
      else
        self.healthy = true
        log "Finished #{performer} in %.2f seconds" % (Time.now - last_performed_at)
      ensure
        save
      end
    end

    def log_error(message)
      log(message, Logger::ERROR)
    end

    def log(message, severity = Logger::INFO)
      @semaphore.synchronize do
        logger.log severity, message
        job_logger.log severity, message
      end
    end

    def model
      @model ||= Crono::CronoJob.find_or_create_by(job_id: job_id)
    end
  end
end
