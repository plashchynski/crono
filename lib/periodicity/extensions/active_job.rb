module Periodicity
  module Extensions
    class ActiveJob
      def self.perform_every(period, *args)
        @period = period
      end
    end
  end
end
