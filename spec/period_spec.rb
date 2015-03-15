require 'spec_helper'

describe Crono::Period do
  around(:each) do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#description' do
    it 'should return period description' do
      @period = Crono::Period.new(1.week, on: :monday, at: '15:20')
      expect(@period.description).to be_eql('every 7 days at 15:20 on Monday')
    end
  end

  describe '#next' do
    context 'in weakly basis' do
      it "should raise error if 'on' is wrong" do
        expect { @period = Crono::Period.new(7.days, on: :bad_day) }
          .to raise_error("Wrong 'on' day")
      end

      it 'should raise error when period is less than 1 week' do
        expect { @period = Crono::Period.new(6.days, on: :monday) }
          .to raise_error("period should be at least 1 week to use 'on'")
      end

      it "should return a 'on' day" do
        @period = Crono::Period.new(1.week, on: :thursday, at: '15:30')
        current_week = Time.now.beginning_of_week
        last_run_time = current_week.advance(days: 1) # last run on the tuesday
        next_run_at = Time.now.next_week.advance(days: 3)
                      .change(hour: 15, min: 30)
        expect(@period.next(since: last_run_time)).to be_eql(next_run_at)
      end

      it "should return a next week day 'on'" do
        @period = Crono::Period.new(1.week, on: :thursday)
        Timecop.freeze(Time.now.beginning_of_week.advance(days: 4)) do
          expect(@period.next).to be_eql(Time.now.next_week.advance(days: 3))
        end
      end

      it 'should return a current week day on the first run if not too late' do
        @period = Crono::Period.new(7.days, on: :tuesday)
        beginning_of_the_week = Time.now.beginning_of_week
        tuesday = beginning_of_the_week.advance(days: 1)
        Timecop.freeze(beginning_of_the_week) do
          expect(@period.next).to be_eql(tuesday)
        end
      end
    end

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
