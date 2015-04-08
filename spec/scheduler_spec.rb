require 'spec_helper'

describe Crono::Scheduler do
  let(:scheduler) { Crono::Scheduler.new }

  describe '#add_job' do
    it 'should call Job#load on Job' do
      @job = Crono::Job.new(TestJob, Crono::Period.new(10.day, at: '04:05'))
      expect(@job).to receive(:load)
      scheduler.add_job(@job)
    end
  end

  describe '#next_jobs' do
    it 'should return next job in schedule' do
      scheduler.jobs = jobs = [
        Crono::Period.new(3.days, at: 10.minutes.from_now.strftime('%H:%M')),
        Crono::Period.new(1.day, at: 20.minutes.from_now.strftime('%H:%M')),
        Crono::Period.new(7.days, at: 40.minutes.from_now.strftime('%H:%M'))
      ].map { |period| Crono::Job.new(TestJob, period) }

      time, jobs = scheduler.next_jobs
      expect(jobs).to be_eql [jobs[0]]
    end

    it 'should return an array of jobs scheduled at same time' do
      time = 5.minutes.from_now
      scheduler.jobs = jobs = [
        Crono::Period.new(1.day, at: time.strftime('%H:%M')),
        Crono::Period.new(1.day, at: time.strftime('%H:%M')),
        Crono::Period.new(1.day, at: 10.minutes.from_now.strftime('%H:%M'))
      ].map { |period| Crono::Job.new(TestJob, period) }

      time, jobs = scheduler.next_jobs
      expect(jobs).to be_eql [jobs[0], jobs[1]]
    end
  end
end
