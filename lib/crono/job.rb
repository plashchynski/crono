require 'stringio'
require 'logger'

module Crono
  # Crono::Job represents a Crono job
  class Job
    include Logging

    attr_accessor :performer, :period, :data, :last_performed_at,
                  :next_performed_at, :job_log, :job_logger, :healthy, :execution_interval

    def initialize(performer, period, data)
      self.execution_interval = 0.minutes
      self.performer, self.period = performer, period
      self.data = JSON.generate(data) if data
      self.job_log = StringIO.new
      self.job_logger = Logger.new(job_log)
      self.next_performed_at = period.next
      @semaphore = Mutex.new
    end

    def next
      return next_performed_at if next_performed_at.future?
      Time.now
    end

    def description
      "Perform #{performer} #{period.description}"
    end

    def job_id
      description
    end

    def perform
      return Thread.new {} if perform_before_interval?

      log "Perform #{performer}"
      self.last_performed_at = Time.now
      self.next_performed_at = period.next(since: last_performed_at)

      Thread.new { perform_job }
    end

    def save
      @semaphore.synchronize do
        update_model
        clear_job_log
        ActiveRecord::Base.clear_active_connections!
      end
    end

    def load
      self.last_performed_at = model.last_performed_at
      self.next_performed_at = period.next(since: last_performed_at)
    end

    private

    def clear_job_log
      job_log.truncate(job_log.rewind)
    end

    def update_model
      saved_log = model.reload.log || ''
      log_to_save = saved_log + job_log.string
      model.update(last_performed_at: last_performed_at, log: log_to_save,
                   healthy: healthy, data: data)
    end

    def perform_job
      args = []
      args << JSON.parse(data) if data
      performer.new(*args).perform 
    rescue StandardError => e
      handle_job_fail(e)
    else
      handle_job_success
    ensure
      save
    end

    def handle_job_fail(exception)
      finished_time_sec = format('%.2f', Time.now - last_performed_at)
      self.healthy = false
      log_error "Finished #{performer} in #{finished_time_sec} seconds"\
                " with error: #{exception.message}"
      log_error exception.backtrace.join("\n")
    end

    def handle_job_success
      finished_time_sec = format('%.2f', Time.now - last_performed_at)
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

    def perform_before_interval?
      return false if execution_interval == 0.minutes

      return true if self.last_performed_at.present? && self.last_performed_at > execution_interval.ago
      return true if model.updated_at.present? && model.created_at != model.updated_at && model.updated_at > execution_interval.ago

      Crono::CronoJob.transaction do
        job_record = Crono::CronoJob.where(job_id: job_id).lock(true).first

        return true if  job_record.updated_at.present? &&
                        job_record.updated_at != job_record.created_at &&
                        job_record.updated_at > execution_interval.ago

        job_record.touch

        return true unless job_record.save
      end

      # Means that this node is permit to perform the job.
      return false
    end
  end
end
