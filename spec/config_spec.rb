require "spec_helper"

describe Crono::Config do
  describe "#initialize" do
    it "should initialize schedule with an empty array" do
      @config = Crono::Config.instance
      expect(@config.schedule).to eql([])
    end
  end
end
