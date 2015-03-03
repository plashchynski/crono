require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::Schedule do
  describe "#add" do
    it "should add an entry to schedule" do
      @schedule = Crono::Schedule.new
      @period = Crono::Period.new(1.day)
      @schedule.add(TestJob, @period)
    end
  end
end
