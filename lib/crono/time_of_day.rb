module Crono
  # TimeOfDay describes a certain hour and minute (on any day)
  class TimeOfDay
    include Comparable

    attr_accessor :hour, :min

    def self.parse(value)
      case value
      when String
        time = Time.parse(value)
        new time.hour, time.min
      when Hash
        new value[:hour], value[:min]
      when Time
        new value.hour, value.min
      else
        fail "Unknown TimeOfDay format: #{value.inspect}"
      end
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
