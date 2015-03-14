require 'stringio'
require 'logger'

module Crono
  # Crono::Job represents a Crono job
  class Job
    include Logging

    attr_accessor :performer, :period, :last_performed_at, :job_log,
                  :job_logger, :healthy

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
        update_model
        clear_job_log
      end
    end

    def load
      self.last_performed_at = model.last_performed_at
    end

    private

    def clear_job_log
      job_log.truncate(job_log.rewind)
    end

    def update_model
      saved_log = model.reload.log || ''
      log_to_save = saved_log + job_log.string
      model.update(last_performed_at: last_performed_at, log: log_to_save,
                   healthy: healthy)
    end

    def perform_job
      performer.new.perform
      finished_time_sec = format('%.2f', Time.now - last_performed_at)
    rescue StandardError => e
      handle_job_fail(e, finished_time_sec)
    else
      handle_job_success(finished_time_sec)
    ensure
      save
    end

    def handle_job_fail(exception, finished_time_sec)
      self.healthy = false
      log_error "Finished #{performer} in #{finished_time_sec} seconds"\
                "with error: #{exception.message}"
      log_error exception.backtrace.join("\n")
    end

    def handle_job_success(finished_time_sec)
      self.healthy = true
      log "Finished #{performer} in #{finished_time_sec} seconds"
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
