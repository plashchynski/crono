module Periodicity
  module Extensions
    module ActiveJob
      def perform_every(period, *args)
        @period = Period.new(period, *args)
      end
    end
  end
end
