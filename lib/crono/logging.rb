module Crono
  mattr_accessor :logger

  module Logging
    def set_log_to(logfile)
      Crono.logger = Logger.new(logfile)
    end

    def logger
      Crono.logger
    end
  end
end
