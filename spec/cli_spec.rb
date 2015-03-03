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
      expect(cli).to receive(:write_pid)
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
      expect(cli.config.cronotab).to be_eql "/tmp/cronotab.rb"
    end

    it "should set logfile" do
      cli.send(:parse_options, ["--logfile", "log/crono.log"])
      expect(cli.config.logfile).to be_eql "log/crono.log"
    end

    it "should set pidfile" do
      cli.send(:parse_options, ["--pidfile", "tmp/pids/crono.0.log"])
      expect(cli.config.pidfile).to be_eql "tmp/pids/crono.0.log"
    end

    it "should set daemonize" do
      cli.send(:parse_options, ["--daemonize"])
      expect(cli.config.daemonize).to be true
    end
  end
end
