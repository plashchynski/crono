module Crono
  # Period describe frequency of performing a task
  class Period
    def initialize(period, at: nil)
      @period = period
      @at_hour, @at_min = parse_at(at) if at
    end

    def next(since: nil)
      if since.nil?
        @next = Time.now.change(time_atts)
        return @next if @next.future?
        since = Time.now
      end

      @period.since(since).change(time_atts)
    end

    def description
      desc = "every #{@period.inspect}"
      desc += format(' at %.2i:%.2i', @at_hour, @at_min) if @at_hour && @at_min
      desc
    end

    def parse_at(at)
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

    private

    def time_atts
      { hour: @at_hour, min: @at_min }.compact
    end
  end
end
