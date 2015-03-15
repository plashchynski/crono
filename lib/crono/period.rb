module Crono
  # Period describe frequency of performing a task
  class Period
    DAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday,
            :sunday]

    def initialize(period, at: nil, on: nil)
      @period = period
      @at_hour, @at_min = parse_at(at) if at
      @on = parse_on(on) if on
    end

    def next(since: nil)
      return initial_next unless since
      @next = @period.since(since)
      @next = @next.beginning_of_week.advance(days: @on) if @on
      @next.change(time_atts)
    end

    def description
      desc = "every #{@period.inspect}"
      desc += format(' at %.2i:%.2i', @at_hour, @at_min) if @at_hour && @at_min
      desc += " on #{DAYS[@on].capitalize}" if @on
      desc
    end

    private

    def initial_next
      next_time = initial_day.change(time_atts)
      return next_time if next_time.future?
      @period.from_now.change(time_atts)
    end

    def initial_day
      return Time.now unless @on
      day = Time.now.beginning_of_week.advance(days: @on)
      return day if day.future?
      @period.from_now.beginning_of_week.advance(days: @on)
    end

    def parse_on(on)
      day_number = DAYS.index(on)
      fail "Wrong 'on' day" unless day_number
      fail "period should be at least 1 week to use 'on'" if @period < 1.week
      day_number
    end

    def parse_at(at)
      fail "period should be at least 1 day to use 'at'" if @period < 1.day
      case at
      when String
        time = Time.parse(at)
        return time.hour, time.min
      when Hash
        return at[:hour], at[:min]
      else
        fail "Unknown 'at' format"
      end
    end

    def time_atts
      { hour: @at_hour, min: @at_min }.compact
    end
  end
end
