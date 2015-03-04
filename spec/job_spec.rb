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
  end
end
