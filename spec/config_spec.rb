require "spec_helper"

describe Crono::Config do
  describe "#initialize" do
    it "should initialize schedule" do
      @config = Crono::Config.new
      expect(@config.cronotab).to be Crono::Config::CRONOTAB
      expect(@config.logfile).to be Crono::Config::LOGFILE
      expect(@config.daemonize).to be false
    end
  end
end
