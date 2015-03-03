require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::Schedule do
  describe "#next" do
    it "should return next job in schedule" do
      @schedule = Crono::Schedule.new
      [
        Crono::Period.new(3.day, at: "18:55"),
        Crono::Period.new(1.day, at: "15:30"),
        Crono::Period.new(7.day, at: "06:05")
      ].each { |period| @schedule.add(TestJob, period) }

      expect(@schedule.next).to be_eql([TestJob, 1.day.from_now.change(hour: 15, min: 30)])
    end
  end
end
