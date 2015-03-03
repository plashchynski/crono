require "spec_helper"
require 'crono/cli'

describe Crono::CLI do
  let(:cli) { Crono::CLI.instance }

  describe "#run" do
    it "should try to initialize rails with #load_rails" do
      expect(cli).to receive(:load_rails)
      cli.run
    end
  end
end
