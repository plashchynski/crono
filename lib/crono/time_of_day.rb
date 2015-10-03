module Crono
  # TimeOfDay describes a certain hour and minute (on any day)
  class TimeOfDay
    include Comparable

    attr_accessor :hour, :min

    def self.parse(value)
      time =
        case value
        when String then Time.parse(value).utc
        when Hash   then Time.now.change(value).utc
        when Time   then value.utc
        else
          fail "Unknown TimeOfDay format: #{value.inspect}"
        end
      new time.hour, time.min
    end

    def initialize(hour, min)
      @hour, @min = hour, min
    end

    def to_i
      @hour * 60 + @min
    end

    def to_s
      '%02d:%02d' % [@hour, @min]
    end

    def <=>(other)
      to_i <=> other.to_i
    end
  end
end
