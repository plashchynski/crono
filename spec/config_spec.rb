require "spec_helper"

describe Periodicity::Config do
  describe "#initialize" do
    it "should initialize schedule with an empty array" do
      @config = Periodicity::Config.instance
      expect(@config.schedule).to eql([])
    end
  end
end
