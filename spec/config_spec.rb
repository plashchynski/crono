require 'spec_helper'

describe Crono::Config do
  let(:config) { Crono::Config.new }
  describe '#initialize' do
    it 'should initialize with default configuration options' do
      ENV['RAILS_ENV'] = 'test'
      @config = Crono::Config.new
      expect(@config.cronotab).to be Crono::Config::CRONOTAB
      expect(@config.logfile).to be Crono::Config::LOGFILE
      expect(@config.piddir).to be Crono::Config::PIDDIR
      expect(@config.process_name).to be Crono::Config::PROCESS_NAME
      expect(@config.daemonize).to be false
      expect(@config.deprecated_daemonize).to be false
      expect(@config.monitor).to be false
      expect(@config.environment).to be_eql ENV['RAILS_ENV']
    end

    describe "#pidfile" do
      subject(:pidfile) { config.pidfile }

      context "not explicity configured" do
        context "daemonize is false" do
          before { config.daemonize = false }

          specify { expect(pidfile).to be_nil }
        end

        context "deprecated_daemonize is true" do
          before { config.deprecated_daemonize = true }

          specify { expect(pidfile).to eq Crono::Config::PIDFILE }
        end
      end

      context "explicity configured" do
        let(:path) { "foo/bar/pid.pid" }

        before { config.pidfile = path }

        specify { expect(pidfile).to eq path }

        it "trys to set piddir" do
          expect(config.piddir).to eq "foo/bar"
        end

        it "trys to set process_name" do
          expect(config.process_name).to eq "pid"
        end
      end

    end
  end
end
