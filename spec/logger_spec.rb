require "spec_helper"

describe Crono::Logger do
  describe "#initialize" do
    it "should initialize logger" do
      expect {
        Crono.logger.info("Test")
      }.to_not raise_error
    end
  end
end
