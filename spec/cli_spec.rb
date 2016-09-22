require 'spec_helper'
require 'crono/cli'

describe Crono::CLI do
  let(:cli) { Crono::CLI.instance }

  describe '#run' do
    it 'should initialize rails with #load_rails and start working loop' do
      expect(cli).to receive(:load_rails)
      expect(cli).to receive(:have_jobs?).and_return(true)
      expect(cli).to receive(:start_working_loop)
      expect(cli).to receive(:parse_options)
      expect(cli).to receive(:parse_command)
      expect(cli).to receive(:write_pid)
      expect(Crono::Cronotab).to receive(:process)
      cli.run
    end

    context 'should run as daemon' do
      before { cli.config.daemonize = true }

      it 'should initialize rails with #load_rails and start working loop' do
        expect(cli).to receive(:load_rails)
        expect(cli).to receive(:have_jobs?).and_return(true)
        expect(cli).to receive(:start_working_loop_in_daemon)
        expect(cli).to receive(:parse_options)
        expect(cli).to receive(:parse_command)
        expect(cli).not_to receive(:write_pid)
        expect(Crono::Cronotab).to receive(:process)
        cli.run
      end
    end
  end

  describe '#parse_options' do
    it 'should set cronotab' do
      cli.send(:parse_options, ['--cronotab', '/tmp/cronotab.rb'])
      expect(cli.config.cronotab).to be_eql '/tmp/cronotab.rb'
    end

    it 'should set logfile' do
      cli.send(:parse_options, ['--logfile', 'log/crono.log'])
      expect(cli.config.logfile).to be_eql 'log/crono.log'
    end

    it 'should set pidfile' do
      cli.send(:parse_options, ['--pidfile', 'tmp/pids/crono.0.log'])
      expect(cli.config.pidfile).to be_eql 'tmp/pids/crono.0.log'
    end

    it 'should set piddir' do
      cli.send(:parse_options, ['--piddir', 'tmp/pids'])
      expect(cli.config.piddir).to be_eql 'tmp/pids'
    end

    it 'should set process_name' do
      cli.send(:parse_options, ['--process_name', 'crono0'])
      expect(cli.config.process_name).to be_eql 'crono0'
    end

    it 'should set monitor' do
      cli.send(:parse_options, ['--monitor'])
      expect(cli.config.monitor).to be true
    end

    it 'should set deprecated_daemonize' do
      cli.send(:parse_options, ['--daemonize'])
      expect(cli.config.deprecated_daemonize).to be true
    end

    it 'should set environment' do
      cli.send(:parse_options, ['--environment', 'production'])
      expect(cli.config.environment).to be_eql('production')
    end
  end

  describe '#parse_command' do

    it 'should set daemonize on start' do
      cli.send(:parse_command, ['start'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on stop' do
      cli.send(:parse_command, ['stop'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on restart' do
      cli.send(:parse_command, ['restart'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on run' do
      cli.send(:parse_command, ['run'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on zap' do
      cli.send(:parse_command, ['zap'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on reload' do
      cli.send(:parse_command, ['reload'])
      expect(cli.config.daemonize).to be true
    end

    it 'should set daemonize on status' do
      cli.send(:parse_command, ['status'])
      expect(cli.config.daemonize).to be true
    end
  end
end
