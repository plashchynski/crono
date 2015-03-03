require "spec_helper"

class TestJob
  def perform;end
end

describe Crono::PerformerProxy do
  it "should add job and period to schedule" do
    expect(Crono.config.schedule).to receive(:add).with(TestJob, kind_of(Crono::Period))
    Crono.perform(TestJob).every(2.days, at: "15:30")
  end
end
