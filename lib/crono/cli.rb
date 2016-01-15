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

      write_pid unless config.daemonize
      load_rails
      Cronotab.process(File.expand_path(config.cronotab))
      print_banner

      check_jobs
      if config.daemonize
        start_working_loop_in_daemon
      else
        start_working_loop
      end
    end

    private

    def setup_log
      if config.daemonize
        self.logfile = config.logfile
      elsif config.deprecated_daemonize
        self.logfile = config.logfile
        deprecated_daemonize
      else
        self.logfile = STDOUT
      end
    end

    def deprecated_daemonize
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
                    " next time will perform at #{job.next}"
      end
    end

    def load_rails
      ENV['RACK_ENV'] = ENV['RAILS_ENV'] = config.environment
      require 'rails'
      require File.expand_path('config/environment.rb')
      ::Rails.application.eager_load! if config.daemonize
    end

    def check_jobs
      return if Crono.scheduler.jobs.present?
      logger.error "You have no jobs in you cronotab file #{config.cronotab}"
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
        sleep(next_time - Time.now) if next_time > Time.now
        jobs.each(&:perform)
      end
    end

    def parse_options(argv)
      @argv = OptionParser.new do |opts|
        opts.banner = "Usage: crono [options] start|stop|restart|run"

        opts.on("-C", "--cronotab PATH", "Path to cronotab file (Default: #{config.cronotab})") do |cronotab|
          config.cronotab = cronotab
        end

        opts.on("-L", "--logfile PATH", "Path to writable logfile (Default: #{config.logfile})") do |logfile|
          config.logfile = logfile
        end

        opts.on("-P", "--pidfile PATH", "Path to pidfile (Default: #{config.pidfile})") do |pidfile|
          config.pidfile = pidfile
        end

        opts.on("--piddir PATH", "Path to piddir (Default: #{config.piddir})") do |piddir|
          config.piddir = piddir
        end

        opts.on("-N", "--process_name name", "Name of the process (Default: #{config.process_name})") do |process_name|
          config.process_name = process_name
        end

        opts.on("-d", "--[no-]daemonize", "Deprecated! Instead use crono [start|stop|restart] without this option; Daemonize process (Default: #{config.daemonize})") do |daemonize|
          config.deprecated_daemonize = daemonize
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
