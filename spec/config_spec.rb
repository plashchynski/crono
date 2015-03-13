require 'spec_helper'

describe Crono::Config do
  describe '#initialize' do
    it 'should initialize with default configuration options' do
      ENV['RAILS_ENV'] = 'test'
      @config = Crono::Config.new
      expect(@config.cronotab).to be Crono::Config::CRONOTAB
      expect(@config.logfile).to be Crono::Config::LOGFILE
      expect(@config.pidfile).to be Crono::Config::PIDFILE
      expect(@config.daemonize).to be false
      expect(@config.environment).to be_eql ENV['RAILS_ENV']
    end
  end
end
