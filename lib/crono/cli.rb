require 'crono'

module Crono
  class CLI
    include Singleton

    def run
      load_rails
      print_banner
      # start_working_loop
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
      Config.instance.schedule.each do |klass, period|
        run_job(klass)
      end
    end
  end
end
