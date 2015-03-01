module Periodicity
  module Extensions
    class ActiveJob
      def self.perform_every(period, *args)
        @period = Period.new(period, *args)
      end
    end
  end
end
