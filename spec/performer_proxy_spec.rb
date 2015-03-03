require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::PerformerProxy do
  it "should add job and period to schedule" do
    Crono.perform(TestJob).every(2.days, at: "15:30")
    expect(Crono::Config.instance.schedule).to_not be_empty
  end
end
