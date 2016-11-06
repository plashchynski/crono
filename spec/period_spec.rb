require 'spec_helper'

describe Crono::Period do
  describe '#description' do
    it 'should return period description' do
      @period = Crono::Period.new(1.week, on: :monday, at: '15:20')
      expected_description = if ActiveSupport::VERSION::MAJOR >= 5
          'every 1 week at 15:20 on Monday'
        else
          'every 7 days at 15:20 on Monday'
        end
      expect(@period.description).to be_eql(expected_description)
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

      it 'should return today on the first run if not too late' do
        @period = Crono::Period.new(1.week, on: :sunday, at: '22:00')
        Timecop.freeze(Time.now.beginning_of_week.advance(days: 6)
                           .change(hour: 21, min: 0)) do
          expect(@period.next).to be_eql(
            Time.now.beginning_of_week.advance(days: 6).change(hour: 22, min: 0)
          )
        end
      end
    end

    context 'in daily basis' do
      it "should return Time.now if the next time in past" do
        @period = Crono::Period.new(1.day, at: '06:00')
        expect(@period.next(since: 2.days.ago).to_s).to be_eql(Time.now.to_s)
      end

      it 'should return time 2 days from now' do
        @period = Crono::Period.new(2.day)
        expect(@period.next.to_s).to be_eql(2.days.from_now.to_s)
      end

      it "should set time to 'at' time as a string" do
        time = 10.minutes.ago
        at = [time.hour, time.min].join(':')
        @period = Crono::Period.new(2.days, at: at)
        expect(@period.next.to_s).to be_eql(2.days.from_now.change(hour: time.hour, min: time.min).to_s)
      end

      it "should set time to 'at' time as a hash" do
        time = 10.minutes.ago
        at = { hour: time.hour, min: time.min }
        @period = Crono::Period.new(2.days, at: at)
        expect(@period.next.to_s).to be_eql(2.days.from_now.change(at).to_s)
      end

      it "should raise error when 'at' is wrong" do
        expect {
          Crono::Period.new(2.days, at: 1)
        }.to raise_error("Unknown 'at' format")
      end

      it 'should raise error when period is less than 1 day' do
        expect {
          Crono::Period.new(5.hours, at: '15:30')
        }.to raise_error("period should be at least 1 day to use 'at' with specified hour")
      end

      it 'should return time in relation to last time' do
        @period = Crono::Period.new(2.days)
        expect(@period.next(since: 1.day.ago).to_s).to be_eql(1.day.from_now.to_s)
      end

      it 'should return today time if it is first run and not too late' do
        time = 10.minutes.from_now
        at = { hour: time.hour, min: time.min }
        @period = Crono::Period.new(2.days, at: at)
        expect(@period.next.utc.to_s).to be_eql(Time.now.change(at).utc.to_s)
      end
    end

    context 'in hourly basis' do
      it 'should return next hour minutes if current hour minutes passed' do
        Timecop.freeze(Time.now.beginning_of_hour.advance(minutes: 20)) do
          @period = Crono::Period.new(1.hour, at: { min: 15 })
          expect(@period.next.utc.to_s).to be_eql 1.hour.from_now.beginning_of_hour.advance(minutes: 15).utc.to_s
        end
      end

      it 'should return current hour minutes if current hour minutes not passed yet' do
        Timecop.freeze(Time.now.beginning_of_hour.advance(minutes: 10)) do
          @period = Crono::Period.new(1.hour, at: { min: 15 })
          expect(@period.next.utc.to_s).to be_eql Time.now.beginning_of_hour.advance(minutes: 15).utc.to_s
        end
      end

      it 'should return next hour minutes within the given interval' do
        Timecop.freeze(Time.now.change(hour: 16, min: 10)) do
          @period = Crono::Period.new(1.hour, at: { min: 15 }, within: '08:00-16:00')
          expect(@period.next.utc.to_s).to be_eql Time.now.tomorrow.change(hour: 8, min: 15).utc.to_s
        end
        Timecop.freeze(Time.now.change(hour: 16, min: 10)) do
          @period = Crono::Period.new(1.hour, at: { min: 15 }, within: '23:00-07:00')
          expect(@period.next.utc.to_s).to be_eql Time.now.change(hour: 23, min: 15).utc.to_s
        end
      end
    end
  end
end
