module Periodicity
  module Extensions
    module ActiveJob
      def perform_every(period, *args)
        Config.instance.schedule += [self, Period.new(period, *args)]
      end
    end
  end
end
