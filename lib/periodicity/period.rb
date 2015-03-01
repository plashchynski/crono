module Periodicity
  class Period
    def initialize(period)
      @period = period
    end

    def next
      @period.from_now
    end
  end
end
