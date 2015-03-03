require 'crono'
require 'optparse'

module Crono
  class CLI
    include Singleton

    def run
      parse_options(ARGV)
      load_rails
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
      require File.expand_path(Crono.config.cronotab)
    end

    def run_job(klass)
      puts "Perform #{klass}"
      Thread.new { klass.new.perform }
    end

    def start_working_loop
      loop do
        klass, time = config.schedule.next
        sleep(time - Time.now)
        run_job(klass)
      end
    end

    def parse_options(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: crono [options]"

        opts.on("-C", "--cronotab PATH", "Path to cronotab file (Default: #{Crono.config.cronotab})") do |cronotab|
          Crono.config.cronotab = cronotab
        end

        opts.on("-L", "--logfile PATH", "Path to writable logfile (Default: #{Crono.config.logfile})") do |logfile|
          Crono.config.logfile = logfile
        end
      end.parse!(argv)
    end
  end
end
