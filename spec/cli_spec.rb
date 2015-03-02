require "spec_helper"
require 'periodicity/cli'

describe Periodicity::CLI do
  let(:cli) { Periodicity::CLI.instance }

  describe "#run" do
    it "should try to initialize rails with #load_rails" do
      expect(cli).to receive(:load_rails)
      cli.run
    end
  end
end
