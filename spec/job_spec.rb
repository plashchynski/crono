require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::Job do
  let(:period) { Crono::Period.new(2.day) }
  let(:job) { Crono::Job.new(TestJob, period) } 

  it "should contain performer and period" do
    expect(job.performer).to be TestJob
    expect(job.period).to be period
  end

  describe "#perform" do
    it "should run performer in separate thread" do
      thread = job.perform.join
      expect(thread).to be_stop
    end

    it "should call Job#save during perform" do
      expect(job).to receive(:save)
      job.perform.join
      job.send(:model).destroy
    end
  end

  describe "#description" do
    it "should return job identificator" do
      expect(job.description).to be_eql("Perform TestJob every 2 days")
    end
  end

  describe "#save" do
    it "should save new job to DB" do
      expect(Crono::CronoJob.where(job_id: job.job_id)).to_not exist
      job.save
      expect(Crono::CronoJob.where(job_id: job.job_id)).to exist
    end

    it "should update saved job" do
      job.last_performed_at = Time.now
      job.save
      @crono_job = Crono::CronoJob.find_by(job_id: job.job_id)
      expect(@crono_job.last_performed_at.utc).to be_eql job.last_performed_at.utc
    end

    it "should save and truncate job log" do
      message = "test message"
      job.send(:log, message)
      job.save
      expect(job.send(:model).reload.log).to include message
      expect(job.job_log.string).to be_empty
    end
  end

  describe "#load" do
    before do
      @saved_last_performed_at = job.last_performed_at = Time.now
      job.save
    end

    it "should load last_performed_at from DB" do
      @job = Crono::Job.new(TestJob, period)
      @job.load
      expect(@job.last_performed_at.utc).to be_eql @saved_last_performed_at.utc
    end
  end

  describe "#log" do
    it "should write log messages to both common and job log" do
      message = "Test message"
      expect(job.logger).to receive(:info).with(message)
      expect(job.job_logger).to receive(:info).with(message)
      job.send(:log, message)
    end

    it "should write job log to Job#job_log" do
      message = "Test message"
      job.send(:log, message)
      expect(job.job_log.string).to include(message)
    end
  end
end
