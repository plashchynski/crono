require "spec_helper"

describe Crono::Config do
  describe "#initialize" do
    it "should initialize schedule" do
      @config = Crono::Config.instance
      expect(@config.schedule).to be_a(Crono::Schedule)
    end
  end
end
