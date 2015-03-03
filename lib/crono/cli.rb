require 'crono'

module Crono
  class CLI
    include Singleton

    def run
      load_rails
      require File.expand_path("config/cronotab.rb")
      print_banner
      start_working_loop
    end

  private
    def print_banner
      puts "Loading Crono #{Crono::VERSION}"
      puts "Running in #{RUBY_DESCRIPTION}"
    end

    def load_rails
      require 'rails'
      require File.expand_path("config/environment.rb")
      ::Rails.application.eager_load!
    end

    def run_job(klass)
      Thread.new { klass.new.perform }
    end

    def start_working_loop
      loop do
        klass, time = Config.instance.schedule.next
        sleep(time - Time.now)
        run_job(klass)
      end
    end
  end
end
