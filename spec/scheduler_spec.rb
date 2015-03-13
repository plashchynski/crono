require 'spec_helper'

class TestJob
  def perform
  end
end

describe Crono::Scheduler do
  before(:each) do
    @scheduler = Crono::Scheduler.new
    @jobs = [
      Crono::Period.new(3.day, at: 10.minutes.from_now.strftime('%H:%M')),
      Crono::Period.new(1.day, at: 20.minutes.from_now.strftime('%H:%M')),
      Crono::Period.new(7.day, at: 40.minutes.from_now.strftime('%H:%M'))
    ].map { |period| Crono::Job.new(TestJob, period) }
    @scheduler.jobs = @jobs
  end

  describe '#add_job' do
    it 'should call Job#load on Job' do
      @job = Crono::Job.new(TestJob, Crono::Period.new(10.day, at: '04:05'))
      expect(@job).to receive(:load)
      @scheduler.add_job(@job)
    end
  end

  describe '#next' do
    it 'should return next job in schedule' do
      expect(@scheduler.next).to be @jobs[0]
    end
  end
end
