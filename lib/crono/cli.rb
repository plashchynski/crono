require 'crono'
require 'optparse'

module Crono
  mattr_accessor :schedule

  class CLI
    include Singleton
    attr_accessor :config
    attr_accessor :schedule
    attr_accessor :logger

    def run
      self.config = Config.new
      self.schedule = Schedule.new
      Crono.schedule = schedule

      parse_options(ARGV)

      logfile = config.daemonize ? config.logfile : STDOUT
      self.logger = Logger.new(logfile)
      
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
      require File.expand_path(config.cronotab)
    end

    def run_job(klass)
      puts "Perform #{klass}"
      Thread.new { klass.new.perform }
    end

    def start_working_loop
      loop do
        klass, time = schedule.next
        sleep(time - Time.now)
        run_job(klass)
      end
    end

    def parse_options(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: crono [options]"

        opts.on("-C", "--cronotab PATH", "Path to cronotab file (Default: #{config.cronotab})") do |cronotab|
          config.cronotab = cronotab
        end

        opts.on("-L", "--logfile PATH", "Path to writable logfile (Default: #{config.logfile})") do |logfile|
          config.logfile = logfile
        end

        opts.on("-d", "--[no-]daemonize", "Daemonize process (Default: #{config.daemonize})") do |daemonize|
          config.daemonize = daemonize
        end
        
      end.parse!(argv)
    end
  end
end
