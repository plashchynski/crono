module Crono
  class Schedule
    def initialize
      @schedule = []
    end

    def add(peformer, period)
      @schedule << [peformer, period]
    end

    def next
      [queue.first[0], queue.first[1].next]
    end

    private
    def queue
      @schedule.sort { |a,b| a[1].next <=> b[1].next }
    end
  end
end
