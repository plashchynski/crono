require "spec_helper"
require 'crono/cli'

class TestJob
  def perform;end
end

describe Crono::CLI do
  let(:cli) { Crono::CLI.instance }

  describe "#run" do
    it "should try to initialize rails with #load_rails" do
      expect(cli).to receive(:load_rails)
      cli.run
    end
  end

  describe "#run_job" do
    it "should run job in separate thread" do
      thread = cli.send(:run_job, TestJob).join
      expect(thread).to be_stop
    end
  end
end
