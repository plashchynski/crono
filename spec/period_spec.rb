require 'spec_helper'

describe Crono::Period do
  around(:each) do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#description' do
    it 'should return period description' do
      @period = Crono::Period.new(2.day, at: '15:20')
      expect(@period.description).to be_eql('every 2 days at 15:20')
    end
  end

  describe '#next' do
    context 'in daily basis' do
      it 'should return the time 2 days from now' do
        @period = Crono::Period.new(2.day)
        expect(@period.next).to be_eql(2.day.from_now)
      end

      it "should set time to 'at' time as a string" do
        time = 10.minutes.ago
        at = [time.hour, time.min].join(':')
        @period = Crono::Period.new(2.day, at: at)
        expect(@period.next).to be_eql(2.day.from_now.change(hour: time.hour, min: time.min))
      end

      it "should set time to 'at' time as a hash" do
        time = 10.minutes.ago
        at = { hour: time.hour, min: time.min }
        @period = Crono::Period.new(2.day, at: at)
        expect(@period.next).to be_eql(2.day.from_now.change(at))
      end

      it "should raise error when 'at' is wrong" do
        expect {
          Crono::Period.new(2.day, at: 1)
        }.to raise_error("Unknown 'at' format")
      end

      it 'should return time in relation to last time' do
        @period = Crono::Period.new(2.day)
        expect(@period.next(since: 1.day.ago)).to be_eql(1.day.from_now)
      end

      it 'should return today time if it is first run and not too late' do
        time = 10.minutes.from_now
        at = { hour: time.hour, min: time.min }
        @period = Crono::Period.new(2.day, at: at)
        expect(@period.next.utc.to_s).to be_eql(Time.now.change(at).utc.to_s)
      end
    end
  end
end
