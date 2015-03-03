require "spec_helper"

describe Crono::Period do
  around(:each) do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe "#next" do
    context "in daily basis" do
      it "should return the time 2 days from now" do
        @period = Crono::Period.new(2.day)
        expect(@period.next).to be_eql(2.day.from_now)
      end

      it "should set time to 'at' time as a string" do
        @period = Crono::Period.new(2.day, at: "15:20")
        expect(@period.next).to be_eql(2.day.from_now.change(hour: 15, min: 20))
      end

      it "should set time to 'at' time as a hash" do
        at = {hour: 18, min: 45}
        @period = Crono::Period.new(2.day, at: at)
        expect(@period.next).to be_eql(2.day.from_now.change(at))
      end

      it "should raise error when 'at' is wrong" do
        expect {
          @period = Crono::Period.new(2.day, at: 1)
        }.to raise_error("Unknown 'at' format")
      end
    end
  end
end
