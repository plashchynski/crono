require 'crono'
require 'optparse'

module Crono
  mattr_accessor :schedule
  mattr_accessor :logger

  class CLI
    include Singleton
    attr_accessor :config

    def initialize
      self.config = Config.new
      Crono.schedule = Schedule.new
    end

    def run
      parse_options(ARGV)
      init_logger
      daemonize if config.daemonize
      write_pid
      load_rails
      print_banner
      start_working_loop
    end

  private
    def daemonize
      ::Process.daemon(true, true)

      [$stdout, $stderr].each do |io|
        File.open(config.logfile, 'ab') { |f| io.reopen(f) }
        io.sync = true
      end
      $stdin.reopen("/dev/null")
    end

    def write_pid
      pidfile = File.expand_path(config.pidfile)
      File.write(pidfile, ::Process.pid)
    end

    def init_logger
      logfile = config.daemonize ? config.logfile : STDOUT
      Crono.logger = Logger.new(logfile)
    end

    def print_banner
      Crono.logger.info "Loading Crono #{Crono::VERSION}"
      Crono.logger.info "Running in #{RUBY_DESCRIPTION}"
    end

    def load_rails
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = config.environment
      require 'rails'
      require File.expand_path("config/environment.rb")
      ::Rails.application.eager_load!
      require File.expand_path(config.cronotab)
    end

    def start_working_loop
      loop do
        job = Crono.schedule.next
        sleep(job.next - Time.now)
        job.perform
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
