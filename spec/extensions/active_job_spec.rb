require "spec_helper"

class TestJob < ActiveJob::Base
  def perform;end
end

TestJob.extend(Periodicity::Extensions::ActiveJob)

describe Periodicity::Extensions::ActiveJob do
  describe "#perform_every" do
    it "should add job and period to schedule" do
      TestJob.perform_every(1.second)
      expect(Periodicity::Config.instance.schedule).to_not be_empty
    end
  end
end
