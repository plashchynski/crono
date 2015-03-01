require "spec_helper"

describe Periodicity::Period do
  around(:each) do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe "#next" do
    context "in daily basis" do
      it "should return the time 2 days from now" do
        @period = Periodicity::Period.new(2.day)
        expect(@period.next).to be_eql(2.day.from_now)
      end
    end
  end
end
