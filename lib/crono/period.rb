module Crono
  # Period describe frequency of jobs
  class Period
    DAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday,
            :sunday]

    def initialize(period, at: nil, on: nil, within: nil)
      @period = period
      @at_hour, @at_min = parse_at(at) if at
      @interval = Interval.parse(within) if within
      @on = parse_on(on) if on
    end

    def next(since: nil)
      if @interval
        if since
          @next = @interval.next_within(since, @period)
        else
          return initial_next if @interval.within?(initial_next)
          @next = @interval.next_within(initial_next, @period)
        end
      else
        return initial_next unless since
        @next = @period.since(since)
      end
      @next = @next.beginning_of_week.advance(days: @on) if @on
      @next = @next.change(time_atts)
      return @next if @next.future?
      Time.now
    end

    def description
      desc = "every #{@period.inspect}"
      desc += " between #{@interval.from} and #{@interval.to}" if @interval
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
      if @period < 1.day && (at.is_a? String || at[:hour])
        fail "period should be at least 1 day to use 'at' with specified hour"
      end

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
