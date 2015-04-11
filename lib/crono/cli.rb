require 'crono'
require 'optparse'

module Crono
  # Crono::CLI - The main class for the crono daemon exacutable `bin/crono`
  class CLI
    include Singleton
    include Logging

    attr_accessor :config

    def initialize
      self.config = Config.new
      Crono.scheduler = Scheduler.new
    end

    def run
      parse_options(ARGV)

      setup_log

      write_pid
      load_rails
      print_banner

      check_jobs
      start_working_loop
    end

    private

    def setup_log
      if config.daemonize
        self.logfile = config.logfile
        daemonize
      else
        self.logfile = STDOUT
      end
    end

    def daemonize
      ::Process.daemon(true, true)

      [$stdout, $stderr].each do |io|
        File.open(config.logfile, 'ab') { |f| io.reopen(f) }
        io.sync = true
      end

      $stdin.reopen('/dev/null')
    end

    def write_pid
      return unless config.pidfile
      pidfile = File.expand_path(config.pidfile)
      File.write(pidfile, ::Process.pid)
    end

    def print_banner
      logger.info "Loading Crono #{Crono::VERSION}"
      logger.info "Running in #{RUBY_DESCRIPTION}"

      logger.info 'Jobs:'
      Crono.scheduler.jobs.each do |job|
        logger.info "'#{job.performer}' with rule '#{job.period.description}'"\
                    "next time will perform at #{job.next}"
      end
    end

    def load_rails
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = config.environment
      require 'rails'
      require File.expand_path('config/environment.rb')
      ::Rails.application.eager_load!
      require File.expand_path(config.cronotab)
    end

    def check_jobs
      return if Crono.scheduler.jobs.present?
      logger.error "You have no jobs in you cronotab file #{config.cronotab}"
    end

    def start_working_loop
      while true
        next_time, jobs = Crono.scheduler.next_jobs
        sleep(next_time - Time.now)
        jobs.each(&:perform)
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

        opts.on("-P", "--pidfile PATH", "Path to pidfile (Default: #{config.pidfile})") do |pidfile|
          config.pidfile = pidfile
        end

        opts.on("-d", "--[no-]daemonize", "Daemonize process (Default: #{config.daemonize})") do |daemonize|
          config.daemonize = daemonize
        end

        opts.on '-e', '--environment ENV', "Application environment (Default: #{config.environment})" do |env|
          config.environment = env
        end
      end.parse!(argv)
    end
  end
end
