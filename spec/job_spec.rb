require 'spec_helper'

class TestJob
  def perform(args)
    puts 'Test!'
  end
end

class TestFailingJob
  def perform(args)
    raise 'Some error'
  end
end

describe Crono::Job do
  let(:period) { Crono::Period.new(2.day, at: '15:00') }
  let(:job_args) {[{some: 'data'}]}
  let(:job) { Crono::Job.new(TestJob, period, []) }
  let(:job_with_args) { Crono::Job.new(TestJob, period, job_args) }
  let(:failing_job) { Crono::Job.new(TestFailingJob, period, []) }

  it 'should contain performer and period' do
    expect(job.performer).to be TestJob
    expect(job.period).to be period
  end

  it 'should contain data as JSON String' do
    expect(job_with_args.job_args).to eq '[{"some":"data"}]'
  end

  describe '#next' do
    it 'should return next performing time according to period' do
      expect(job.next).to be_eql period.next
    end
  end

  describe '#perform' do
    after { job.send(:model).destroy }

    it 'should run performer in separate thread' do
      expect(job).to receive(:save)
      thread = job.perform.join
      expect(thread).to be_stop
    end

    it 'should save performin errors to log' do
      thread = failing_job.perform.join
      expect(thread).to be_stop
      saved_log = Crono::CronoJob.find_by(job_id: failing_job.job_id).log
      expect(saved_log).to include 'Some error'
    end

    it 'should set Job#healthy to false if perform with error' do
      failing_job.perform.join
      expect(failing_job.healthy).to be false
    end

    it 'should execute one' do
      job.execution_interval = 5.minutes

      expect(job).to receive(:perform_job).once
      job.perform.join
      thread = job.perform.join
      expect(thread).to be_stop
    end

    it 'should execute twice' do
      job.execution_interval = 0.minutes

      test_preform_job_twice
    end

    it 'should execute twice without initialize execution_interval' do
      test_preform_job_twice
    end

    it 'should call perform of performer' do
      expect(TestJob).to receive(:new).with(no_args)
      thread = job.perform.join
      expect(thread).to be_stop
    end

    it 'should call perform of performer with data' do
      test_job = double()
      expect(TestJob).to receive(:new).and_return(test_job)
      expect(test_job).to receive(:perform).with([{ 'some' => 'data' }])
      thread = job_with_args.perform.join
      expect(thread).to be_stop
    end

    def test_preform_job_twice
      expect(job).to receive(:perform_job).twice
      job.perform.join
      thread = job.perform.join
      expect(thread).to be_stop
    end
  end

  describe '#description' do
    it 'should return job identificator' do
      expect(job.description).to be_eql('Perform TestJob every 2 days at 15:00')
    end
  end

  describe '#save' do
    it 'should save new job to DB' do
      expect(Crono::CronoJob.where(job_id: job.job_id)).to_not exist
      job.save
      expect(Crono::CronoJob.where(job_id: job.job_id)).to exist
    end

    it 'should update saved job' do
      job.last_performed_at = Time.zone.now
      job.healthy = true
      job.job_args = JSON.generate([{some: 'data'}])
      job.save
      @crono_job = Crono::CronoJob.find_by(job_id: job.job_id)
      expect(@crono_job.last_performed_at.utc.to_s).to be_eql job.last_performed_at.utc.to_s
      expect(@crono_job.healthy).to be true
    end

    it 'should save log' do
      message = 'test message'
      job.send(:log, message)
      job.save
      expect(job.send(:model).reload.log).to include message
      expect(job.job_log.string).to be_empty
    end

    it 'should not truncate log if not specified' do
      log = (1..100).map {|n| "line #{n}" }.join("\n")
      job = Crono::Job.new(TestJob, period, [])
      job.send(:log, log)
      job.save
      expect(job.send(:model).reload.log.lines.size).to be >= log.lines.size
    end

    it 'should truncate log if specified' do
      log = (1..100).map {|n| "line #{n}" }.join("\n")
      job = Crono::Job.new(TestJob, period, [], truncate_log: 50)
      job.send(:log, log)
      job.save
      expect(job.send(:model).reload.log.lines.size).to be 50
    end
  end

  describe '#load' do
    before do
      @saved_last_performed_at = job.last_performed_at = Time.zone.now
      job.save
    end

    it 'should load last_performed_at from DB' do
      @job = Crono::Job.new(TestJob, period, job_args)
      @job.load
      expect(@job.last_performed_at.utc.to_s).to be_eql @saved_last_performed_at.utc.to_s
    end
  end

  describe '#log' do
    it 'should write log messages to both common and job log' do
      message = 'Test message'
      job.logfile = "/dev/null"
      expect(job.logger).to receive(:log).with(Logger::INFO, message)
      expect(job.job_logger).to receive(:log).with(Logger::INFO, message)
      job.send(:log, message)
    end

    it 'should write job log to Job#job_log' do
      message = 'Test message'
      job.send(:log, message)
      expect(job.job_log.string).to include(message)
    end
  end

  describe '#log_error' do
    it 'should call log with ERROR severity' do
      message = 'Test message'
      expect(job).to receive(:log).with(message, Logger::ERROR)
      job.send(:log_error, message)
    end
  end
end
