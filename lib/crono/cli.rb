Thread.abort_on_exception = true

require 'crono'
require 'optparse'

module Crono
  # Crono::CLI - The main class for the crono daemon exacutable `bin/crono`
  class CLI
    include Singleton
    include Logging

    COMMANDS = %w(start stop restart run zap reload status)

    attr_accessor :config

    def initialize
      self.config = Config.new
      Crono.scheduler = Scheduler.new
    end

    def run
      parse_options(ARGV)
      parse_command(ARGV)

      setup_log

      write_pid if config.daemonize
      load_rails
      Cronotab.process(File.expand_path(config.cronotab))
      print_banner

      unless have_jobs?
        logger.error "You have no jobs in you cronotab file #{config.cronotab}"
        return
      end

      if config.daemonize
        start_working_loop_in_daemon
      else
        start_working_loop
      end
    end

    private

    def have_jobs?
      Crono.scheduler.jobs.present?
    end

    def setup_log
      if config.daemonize
        self.logfile = config.logfile
      else
        self.logfile = STDOUT
      end
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
                    " next time will perform at #{job.next}"
      end
    end

    def load_rails
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = config.environment
      require 'rails'
      require File.expand_path('config/environment.rb')
      ::Rails.application.eager_load!
    end

    def start_working_loop_in_daemon
      unless ENV['RAILS_ENV'] == 'test'
        begin
          require 'daemons'
        rescue LoadError
          raise "You need to add gem 'daemons' to your Gemfile if you wish to use it."
        end
      end
      Daemons.run_proc(config.process_name, dir: config.piddir, dir_mode: :normal, monitor: config.monitor, ARGV: @argv) do |*_argv|
        Dir.chdir(root)
        Crono.logger = Logger.new(config.logfile)

        start_working_loop
      end
    end

    def root
      @root ||= rails_root_defined? ? ::Rails.root : DIR_PWD
    end

    def rails_root_defined?
      defined?(::Rails.root)
    end

    def start_working_loop
      loop do
        next_time, jobs = Crono.scheduler.next_jobs
        now = Time.zone.now
        sleep(next_time - now) if next_time > now
        jobs.each(&:perform)
      end
    end

    def parse_options(argv)
      @argv = OptionParser.new do |opts|
        opts.banner = "Usage: crono [options] [start|stop|restart|run]"

        opts.on("-C", "--cronotab PATH", "Path to cronotab file (Default: #{config.cronotab})") do |cronotab|
          config.cronotab = cronotab
        end

        opts.on("-L", "--logfile PATH", "Path to writable logfile (Default: #{config.logfile})") do |logfile|
          config.logfile = logfile
        end

        opts.on("-P", "--pidfile PATH", "Deprecated! use --piddir with --process_name; Path to pidfile (Default: #{config.pidfile})") do |pidfile|
          config.pidfile = pidfile
        end

        opts.on("-D", "--piddir PATH", "Path to piddir (Default: #{config.piddir})") do |piddir|
          config.piddir = piddir
        end

        opts.on("-N", "--process_name NAME", "Name of the process (Default: #{config.process_name})") do |process_name|
          config.process_name = process_name
        end

        opts.on("-m", "--monitor", "Start monitor process for a deamon (Default #{config.monitor})") do
          config.monitor = true
        end

        opts.on '-e', '--environment ENV', "Application environment (Default: #{config.environment})" do |env|
          config.environment = env
        end
      end.parse!(argv)
    end

    def parse_command(argv)
      if COMMANDS.include? argv[0]
        config.daemonize = true
      end
    end

  end
end
