require "spec_helper"
require 'crono/cli'

class TestJob
  def perform;end
end

describe Crono::CLI do
  let(:cli) { Crono::CLI.instance }

  describe "#run" do
    it "should try to initialize rails with #load_rails and start working loop" do
      expect(cli).to receive(:load_rails)
      expect(cli).to receive(:start_working_loop)
      expect(cli).to receive(:parse_options)
      cli.run
    end
  end

  describe "#run_job" do
    it "should run job in separate thread" do
      thread = cli.send(:run_job, TestJob).join
      expect(thread).to be_stop
    end
  end

  describe "#start_working_loop" do
    it "should start working loop"
  end

  describe "#parse_options" do
    it "should set cronotab" do
      cli.send(:parse_options, ["--cronotab", "/tmp/cronotab.rb"])
      expect(Crono.config.cronotab).to be_eql "/tmp/cronotab.rb"
    end
  end
end
