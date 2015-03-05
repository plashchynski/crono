module Crono
  class Period
    def initialize(period, at: nil)
      @period = period
      @at_hour, @at_min = parse_at(at) if at
    end

    def next(since: nil)
      since ||= Time.now
      @period.since(since).change({hour: @at_hour, min: @at_min}.compact)
    end

    def description
      desc = "every #{@period.inspect}"
      desc += " at %.2i:%.2i" % [@at_hour, @at_min] if @at_hour && @at_min
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
        raise "Unknown 'at' format"
      end
    end
  end
end
